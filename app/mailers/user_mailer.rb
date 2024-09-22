class UserMailer < ActionMailer::Base
  @url = "http://203.161.43.101:3000"
  default :from => "michael@virtualpianist.com"

  def welcome_venue(venue)
    @venue = venue

    # mail(:to => venue.email, :subject => "Welcome to Virtual Booking Agent")
  end

  def welcome_group(group)
    @group = group

    mail(:to=>group.email, :subject => "Your group has been added")
  end

  def welcome_user(user)
    @user = user

    mail(:to=>user.email, :subject=> "Welcome to Virtual Booking Agent")
  end

  def welcome_guest(user)
    @user = user

    mail(:to=>user.email, :subject=> "Welcome to Virtual Booking Agent")
  end

  def new_concert(concert,user)
    @concert = concert
    @user = user

    @stop_notify = "http://203.161.43.101:3000/users/stop_notification?id=#{@user.id}"
    mail(:to=>user.email, :subject => "A new concert is being offered at Virtual Booking Agent.")
  end

  def newgroup(group,user)
    @group=group
    @user=user
    @stop_notify = "http://203.161.43.101:3000/users/stop_notification?id=#{@user.id}"

    mail(:to=>@user.email, :subject=>'New group added to Virtual Booking Agent')
  end

  def send_password(user,new_password)
    @user = user
    @new_password=new_password
    mail(:to=>@user.email, :subject=>'password reset')
  end

  def login_name(user)
    @user = user
    mail(:to=>@user.email, :subject=>'Login')
  end

  def password_reset_instructions(user)
    @user = user
    @url = "http://203.161.43.101:3000/password_resets/#{user.perishable_token}/edit"
    mail(:to=>@user.email, :subject=>'Password Reset Instructions')
  end

  def booking_request(venue,concert)
    @venue = venue
    @concert = concert
    @group = Group.find(@concert.group_id)
    mail(:to=>@group.email, :subject=>'New Booking Possibility')
  end

  def join_request(user,group)
    mail(:to=>@group.email, :subject=>'Request to join your group, #{group.title}')
  end

end
