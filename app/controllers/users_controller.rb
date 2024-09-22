class UsersController < ApplicationController

  before_action  :require_no_user, :only=>[:new, :create]
  before_action  :require_user, :only=>[:show, :edit, :update]
  before_action  :requre_mst, :only=>[:delete]
  before_action  :check_if_stale, :only=>[:show, :edit, :update]

  def check_if_stale
    if current_user_session.stale?
      redirect_to '/user_sessions/new', :notice => 'Your session has timed out, please log in.'
    end
  end

  def stop_notification
    @user=User.find(params[:id])
    @user.notify=false
    @user.save
  end

  def search #search for a user's login
    @email = params[:email]
    @user = User.find_by_email(@email)
  end

  def new
    @user = User.new
  end

  def guest
    @user = User.new
    @user.login="Guest" + rand.to_s
    @user.password=@user.login
  end

  def register_guest
    @user.create_address = [@user.city, @user.state, @user.zip].join(", ")
    if @user.update(user_params.to_h)
      if @user.login[0..4]=="Guest"
        flash[:notice]="Welcome Guest,  please check your email for instructions."
        UserMailer.welcome_guest(u).deliver_now
      else
        flash[:notice] = "Account registered!"
        UserMailer.welcome_user(u).deliver_now
      end
      redirect_back_or_default :home
    else
      flash[:notice]="Sorry, there was a problem in the users_controller (42). Please let michael@virtualpianist know."
      if @user.login[0..4]=="Guest"
        render :action=>:guest
      else
        render :action => :new
      end
    end
  end



  def musician
  end


  def groups_near_me
    if params["distance"].nil?
      @groups = Group.near(current_user,$SEARCH_RANGE)
      if @groups.is_a?(Array)
        @groups.sort { |a,b| a.title <=> b.title }
      end
      @current_dist = $SEARCH_RANGE
    else
      @groups = Group.near(current_user,params["distance"])
      if @groups.is_a?(Array)
        @groups.sort { |a,b| a.title <=> b.title }
      end
      @current_dist = params["distance"]
    end
    if @groups.nil?
      puts "@groups is nil"
      @groups=[]
    else
      puts @groups.length
    end
  end

  def venues_near_me
        puts "entering venues_near_me"

    if current_user.nil?
      puts "current_user is nil"
    else
      puts "current_user is not nil"
      puts current_user.zip
    end

    if params["distance"].nil?
      @venues = Venue.near(current_user,$SEARCH_RANGE)
      @venues.sort { |a,b| a.name <=> b.name }
      @current_dist = $SEARCH_RANGE
    else
      @venues = Venue.near(current_user,params["distance"])
      puts "found #{@venues.size} Venues"
      @venues.sort { |a,b| a.name <=> b.name }
      @current_dist = params["distance"]
    end
  end

  def join_venue
    @venue = Venue.find(params[:id])
    current_user.venues << @venue
    current_user.save
    redirect_to edit_venue_path(@venue), :notice=>"Please make sure all the information is correct."
  end

  def leave_venue
    @venue = Venue.find(params[:id])
    current_user.venues.delete @venue
    @venue.user_id = nil
    @venue.save
    redirect_to "/venues", :notice=>"You are not connected with #{@venue.name}."
  end

  def join_group
    gid=params[:id]
    g=Group.find(gid)
    if current_user.groups.include? g
      redirect_to :home, :notice=>'You are already a member of this group.'
    else
      m = g.email
      c = g.contact

      current_user.groups << g
      current_user.save
      redirect_to :home, :notice=>"You have joined #{g.title}"
    end
  end

  def leave_group
    gid=params[:id]
    g=Group.find(gid)
    current_user.groups.delete g
    if g.users.length == 0
      g.locked = false
      g.save
    end
    redirect_to :home, :notice=>"You have left the group, #{g.title}"
  end

  def create
    puts params
    if params["commit"] == "Request Login"
      puts "processing request for login"
      @user = User.find_by({:email => params["email"]})
      if @user.nil?
        flash[:notice]="That email was not found."
      else
        login = @user.login.capitalize
        flash[:notice]="Your login is #{login}"
      end
      redirect_back_or_default :home
      return
    else
      @user = User.new(user_params.to_h)
      @user.login.upcase
      if User.find_by({:email => @user.email}).nil?
        @user.address = [@user.city, @user.state, @user.zip].join(", ")
        if @user.save
          if @user.login[0..4]=="Guest"
            begin
              UserMailer.welcome_guest(@user).deliver_now
            rescue
              flash[:notice]="Seems like this email is invalid?"
            else
              flash[:notice]="Welcome Guest"
            end

          else
            flash[:notice] = "Account registered!"
            UserMailer.welcome_user(@user).deliver_now
          end
          redirect_back_or_default :home
        else
          if @user.login[0..4]=="Guest"
            render :action=>:guest
          else
            render :action => :new
          end
        end
      else
        flash[:notice] = "That email exists already. Did you forget your login?"
        redirect_back_or_default :home
      end
    end
  end

  def show
    if params[:id].nil?
      @user = current_user
    else
      @user = User.find(params[:id])
    end
    # @user = @current_user
  end

  def edit
    @user = @current_user
  end

  def delete
    @user = User.find(params[:id])
    @user.destroy
    redirect_to "/admins/allusers"
  end

  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    @user.address = [@user.city, @user.state, @user.zip].join(", ")
    if @user.update(user_params.to_h)
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:login, :email, :zip, :password, :notify, :city, :state)
  end

end
