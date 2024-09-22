class  LoginResetsController < ApplicationController
  before_action  :load_user_using_perishable_token, :only => [:edit, :update]  

  def new
    if request.post?
      @user = User.find_by_email(params[:email])
      if @user.nil?
        flash[:notice]="Can not find that email."
      else
        @user.deliver_login!
        flash[:notice] = "Your login has been sent to your email."
        redirect_to new_user_session_path, :notice => "Your login is #{@user.login}"
      end
      redirect_to '/'
    else
      @user = User.new
    end
  end

  def create
    puts "CREATE"
    puts "params are " +  params
    @user = User.find_by({:email => params["email"]})
    if @user
      @user.deliver_login!
      flash[:notice] = "Your login has been sent to your email."
      redirect_to new_user_session_path, :notice => "Your login is #{@user.login}"
    else
      flash[:notice] = "No user was found with that email address"
      render :action => :new
    end
  end

  def forgot
    puts "FORGOT"
  end


  def edit
    puts "EDIT"
    render
  end


  def show
    if params[:email].nil? or params[:email]==''
      @user = ""
    else
      @user = User.find_by_email(params[:email])
    end

    if @user.nil? or @user==""
      puts "User is nil"
      flash[:notice]='User is nil'
    else
      @user.deliver_login!
      flash[:notice] = "Your login has been sent to your email."
      redirect_to new_user_session_path
    end
    puts "SHOW"
    puts params
    
  end

  def search
    puts "login_reset_controller search"
    puts "email is #{params[:email]}"
    @user = User.find_by_email(params[:email])
    if @user.nil?
      flash[:notice]="Unknown email"
    else
      flash[:notice]="Login is #{@user.login}"
    end
    render '/'
  end



  def update
    puts "UPDATE"
    puts params
  end
  
  private  
  
  def load_user_using_perishable_token  
    @user = User.find_using_perishable_token(params[:id])  
    unless @user  
      flash[:notice] = "We're sorry, but we could not locate your account. " +  
                       "If you are having issues try copying and pasting the URL " +  
                       "from your email into your browser or restarting the " +  
                       "reset password process."  
      redirect_to root_url, :notice=> "We're sorry, but we could not locate your account. " +  
                                      "If you are having issues try copying and pasting the URL " +  
                                      "from your email into your browser or restarting the " +  
                                      "reset password process."
    end
  end
  
end
