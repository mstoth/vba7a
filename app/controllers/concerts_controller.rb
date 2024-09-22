class ConcertsController < ApplicationController

  before_action  :require_mst_or_owner, :only=>[:destroy, :edit, :update]
  before_action  :check_if_stale

  def check_if_stale
    if current_user_session.nil? or current_user_session.stale?
      redirect_to '/user_sessions/new', :notice => 'Your session has timed out, please log in.'
    end
  end

  def venues_near
    @concert = Concert.find(params[:id])
    @venues = Venue.near(@concert,current_user,$SEARCH_RANGE)
  end

  def near_venue
    if !params[:id].nil?
      @venue=Venue.find(params[:id])
      @concerts=Concert.near(@venue,current_user,$SEARCH_RANGE)
    else
      @venue=nil
      @concerts=Concert.all
    end

    @venues=Venue.all
    @groups=Group.all
    @my_venues=current_user.venues
  end

  def printable
    @booked_concerts = current_user.my_concerts(false)
    @concerts = current_user.my_concerts(true)
    @venues = Venue.near(current_user,$SEARCH_RANGE)
    @groups = current_user.groups
    respond_to do |format|
      format.html # printable.html.erb
      format.xml  { render :xml => @concerts }
    end
  end

  # GET /concerts
  # GET /concerts.xml
  def index
    @concerts = []
    current_user.groups.each do |g|
      g.concerts.each do |c|
        @concerts << c
      end
    end

    @personal_concerts = current_user.personal_concerts()
    @booked_concerts = current_user.my_concerts(false)
    @offered_concerts = current_user.my_concerts(true)
    @venues = Venue.near(current_user,$SEARCH_RANGE)
    @groups = current_user.groups
    @previous_concerts = Concert.where("date < ?",Date.today)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @concerts }
    end
  end

  # GET /concerts/1
  # GET /concerts/1.xml
  def show
    @concert = Concert.find(params[:id])
    @venues = Venue.all
    my_groups=current_user.groups
    # determine if owner and allow editing if so.
    @can_edit=false
    if my_groups.length > 0
      my_groups.each do |mg|
	    if @concert.group_id == mg.id
	      @can_edit=true
	    end
    end
  end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @concert }
    end
  end

  # GET /concerts/new
  # GET /concerts/new.xml
  def new
    @concerts = Concert.all()
    @concert = Concert.new
    @venues = Venue.all
    @groups = current_user.groups
    @concert.date = nil
    @concert.start_time = nil
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @concert }
    end
  end

  # GET /concerts/1/edit
  def edit
    @concert = Concert.find(params[:id])
    @concerts = Concert.all()
    @groups = current_user.groups
    @venues = Venue.all
    my_groups=current_user.groups
    @can_edit=false
    if my_groups.length > 0
      my_groups.each do |mg|
	if @concert.group_id == mg.id
	  @can_edit=true
	end
      end
    end
  end

  def addpiece

    @concert = Concert.find(params[:id])

    if (params[:pid].nil? or params[:pid] == "0") and (params[:id].nil? or params[:id] == "0")
      @piece=Piece.new()
    else
      if params[:pid].nil? or params[:pid] == "0"
        @piece = Piece.new()
      else
        @piece = Piece.find(params[:pid])
      end
    end
    @piece.concert_id = @concert.id
    @dummy=Concert.find_by :title=>"Dummy"
    if @dummy.nil?
      @dummy = Concert.new(:title=>"Dummy",:genre=>"none",:zip=>current_user.zip)
      @dummy.save()
    end

    @dummypieces=Piece.where(:concert_id=>@dummy.id)
    if @dummypieces.nil?
      @dummypieces=[]
    end
    if @dummypieces.class == Piece
      @dummypieces = [@dummypieces]
    end
    @concerts=Concert.all
  end

  # POST /concerts
  # POST /concerts.xml
  def create
    @concert = Concert.new(user_params.to_h)
    @concert.create_address

    if @concert.webpage == "" or @concert.webpage.nil?
      @concert.webpage = Group.find(@concert.group_id).website
    end


    if params[:concert][:date] != ""
      @concert.date = DateTime.strptime(params[:concert][:date],"%Y-%m-%d %H:%M")
      @concert.start_time = @concert.date
      if @concert.offer == false # reoffer the concert by default
        cdup = Concert.new()
        cdup.title = @concert.title
        cdup.genre = @concert.genre
        cdup.price = @concert.price
        cdup.group_id = @concert.group_id
        cdup.webpage = @concert.webpage
        cdup.offer = true
        cdup.date = nil
        cdup.venue_id = nil
        cdup.save()
      else
        loc = Geocoder.search(Venue.find(@concert.venue_id).address)
        ll = loc.first.coordinates
        @concert.lat = ll.first
        @concert.lng = ll.last
        @concert.zip = Venue.find(@concert.venue_id).zip
      end
    end

    no_webpage = params["no_webpage"]
    if no_webpage == "true"
      @concert.webpage = Group.find(@concert.group_id).website
    end

    @venues = Venue.near(current_user,$SEARCH_RANGE)
    @groups = current_user.groups

    if !@concert.venue_id.nil?
      @concert.zip = Venue.find(@concert.venue_id).zip
    else
      @concert.zip = Group.find(@concert.group_id).zip
    end

    respond_to do |format|
      if @concert.save
        if  @concert.offer
          send_concert_announcement(@concert)
        end
        format.html { redirect_to(@concert, :notice => 'Concert was successfully created.') }
        format.xml  { render :xml => @concert, :status => :created, :location => @concert }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @concert.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /concerts/duplicate/1
  def duplicate
    @concert = Concert.find(params[:id])
    @new_concert = @concert.dup
    @new_concert.offer = true
    @new_concert.venue_id = nil
    @new_concert.date = nil
    @concert.pieces.each do |p|
      tp = p.dup
      if tp.save()
        @new_concert.pieces << tp
      end
    end

    if @new_concert.save
      redirect_to(@new_concert, :notice => 'Concert was duplicated')
    else
      redirect_to(@concert, :notice => 'There was a problem duplicating this concert.')
    end
  end


  def book
    @concert = Concert.find(params[:id])

    @group = Group.find(@concert.group_id)
    @venues = current_user.venues()
    @venue = @venues.first
    @concerts = Concert.where("group_id = #{@group.id}")
    @booked_concerts = Concert.where("group_id = #{@group.id} and offer = false"    )
    UserMailer.booking_request(@venue,@concert).deliver_now!
    redirect_to(@concert, :notice => "Email was sent to #{@group.title}\r\nYou can expect a reply soon.\r\nYou can call #{@group.contact} at #{@group.phone} if you like.")
  end

  # POST /concerts/1/book
  def reserve
    @concert = Concert.find(params[:id])
    @group = Group.find(@concert.group_id)
  end


  # PUT /concerts/1
  # PUT /concerts/1.xml
  def update
    if request.get? or request.patch?
      @concert = Concert.find(params[:id])
      @concert.create_address
      if params[:concert][:offer]
        @concert.date = nil
        @concert.start_time = nil
      end
      # 2023-02-08 12:00 format
      if params[:concert][:date] != ""
        if !params[:concert][:date].nil?
          @concert.date = DateTime.strptime(params[:concert][:date],'%Y-%m-%e %H:%M')
          @concert.start_time = @concert.date
        end
      else
      end

      @venues = Venue.near(current_user,$SEARCH_RANGE)
      @groups = current_user.groups

      no_webpage = params["no_webpage"]
      if no_webpage == "true"
        params[:concert]["webpage"] = Group.find(@concert.group_id).website
      end

      if !@concert.venue_id.nil?
        params[:concert]["zip"] = Venue.find(@concert.venue_id).zip
      else
        params[:concert]["zip"] = Group.find(@concert.group_id).zip
      end

      respond_to do |format|
        if @concert.update(user_params.to_h)
          format.html { redirect_to(@concert, :notice => 'Concert was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @concert.errors, :status => :unprocessable_entity }
        end
      end
    else
      if params[:commit] == "Update Concert"
        if @concert.nil?
          @concert = Concert.find(params[:id])
          if @concert.nil?
          else
            respond_to do |format|
              if @concert.update(user_params.to_h)
                format.html { redirect_to(@concert, :notice => 'Concert was successfully updated.') }
                format.xml  { head :ok }
              else
                format.html { render :action => "edit" }
                format.xml  { render :xml => @concert.errors, :status => :unprocessable_entity }
              end
            end
          end
        end

      else
        if params[:commit] == "Check Date"
          @concert = Concert.find(params[:id])

          respond_to do |format|
            format.html { redirect_to(@concert, :notice => 'Concert was successfully updated.') }
          end
          flash[:notice] = "Checked Date"
        end
      end
    end
  end

  # DELETE /concerts/1
  # DELETE /concerts/1.xml
  def destroy
    @concert = Concert.find(params[:id])
    @concert.destroy

    respond_to do |format|
      format.html { redirect_to(concerts_url, :notice=> 'Concert was deleted.') }
      format.xml  { head :ok }
    end
  end

  private

  def send_concert_announcement(c)
    venue_list = Venue.near(c,$SEARCH_RANGE)
    venue_list.each do |v|
      if !v.user_id.nil?
        u = User.find(v.user_id)
        if !u.nil? && u.notify
          UserMailer.new_concert(c,u).deliver
        end
      end
    end
  end

  def require_mst_or_owner
    if current_user.nil? then
      return false
    end
    if current_user.login.nil? then
      return false
    end
    if current_user.login == 'mstoth'
      return true
    end
    concert=Concert.find(params[:id])
    group=Group.find(concert.group_id)
    if current_user.groups.include? group
      return true
    end
    render '/agent/error', :notice=>"You do not have permission."
    return false
  end

  private

  def user_params
    params.require(:concert).permit(:title, :genre, :webpage, :group_id, :venue_id, :offer, :price, :display)
  end


end
