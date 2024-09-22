class PasswordResetsController < ApplicationController
before_action  :load_user_using_perishable_token, :only => [:edit, :update]  

def new
  @user = User.find_by_email(params[:email])
  if @user
    @user.deliver_login!
    flash[:notice]="Your login was emailed to you, please check your email."
  else
    flash[:notice]="Sorry, your email could not be found."
  end
end

def show
  @user = User.find_by_email(params[:email])
    if @user
        @user.deliver_password_reset_instructions!
        flash[:notice]="Instructions to reset your password have been emailed to you.
        Please check your email." 
        redirect_to new_user_session_path, :notice=>"Instructions to reset your password have been emailed to you.
        Please check your email."
    else
        flash[:notice] = "No user was found with that email address"
        render :action=>:new
    end
end


def create
  @user = User.find_by_email(params[:email])
    if @user
        @user.deliver_password_reset_instructions!
        flash[:notice]="Instructions to reset your password have been emailed to you.
        Please check your email." 
        redirect_to new_user_session_path, :notice=>"Instructions to reset your password have been emailed to you.
        Please check your email."
    else
        flash[:notice] = "No user was found with that email address"
        render :action=>:new
    end
end

def edit
  render
end

def update
  puts "=== UPDATE ==="
  puts params
    user_params = params[:user]
    if user_params[:password] == user_params[:password_confirmation]
      @user.password = user_params[:password]
      if @user.save()
        flash[:notice] = "Account updated!"
        redirect_to :root
      else
        flash[:notice] = "Unable to update account."
        render :action => :edit
      end
    else
      flash[:notice] = "Passwords do not match \n ${@user.errors.full_messages}" 
    end
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
