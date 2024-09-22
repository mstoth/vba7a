class UserSessionsController < ApplicationController

  before_action  :require_no_user, :only=>[:new,:create]
  before_action  :require_user, :only => :destroy

  def show
    @user=current_user
  end

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(user_params.to_h)
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default :xhome
    else
      render :action => :new
    end
  end

  def destroy
    c=""
    if current_user.login[0..4]=="Guest"
      c=current_user
    end
    current_user_session.destroy
    if c!=""
      if c.login[0..4]=="Guest"
        c.destroy
      end
    end
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end

  private

  def user_params
    params.require(:user_session).permit(:login, :password)
  end


end
