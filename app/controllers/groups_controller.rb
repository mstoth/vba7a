class GroupsController < ApplicationController
  before_action  :require_mst_or_owner, :only=>[:edit, :destroy, :update]
  before_action  :require_not_guest, :except=>[:index, :show]
  before_action  :check_if_stale


  def check_if_stale
    if current_user_session.nil? or current_user_session.stale?
      redirect_to '/user_sessions/new', :notice => 'Your session has timed out, please log in.'
    end
  end

  # GET /groups/join
  def join
    @groups = Group.near(current_user,$SEARCH_RANGE)
    @group_list = []
    @groups.each do |g|
      if g.locked == false
        @group_list << g
      end
    end
    @groups = @group_list
  end

  # GET /groups
  # GET /groups.xml
  def index
    @groups = current_user.groups
    @joinable_groups = Group.where("locked = false")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    @group = Group.find(params[:id])
    @concerts = Concert.where("group_id = #{@group.id}")
    @booked_concerts = Concert.where("group_id = #{@group.id} and offer = false")
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # Get /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  def notify_users_of_new_group(g)
  end

  # POST /groups/:id/admit/:gid
  def admit
    u=User.find(:id)
    g=Group.find(:gid)
    u.groups << g
    if u.save()
      UserMailer.user_joined(u,g).deliver_now
    else
      UserMailer.user_join_failed(u,g).deliver_now
    end
  end

  # POST /groups
  # POST /groups.xml
  def create

    @group = Group.new(user_params.to_h)
    @group.create_address

    respond_to do |format|
      if @group.save
	      current_user.groups << @group
	      current_user.save
	      send_group_announcement(@group)
        format.html { redirect_to(@group, :notice => 'Group was successfully created.') }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])
    @group.create_address

    respond_to do |format|
      if @group.update(user_params.to_h)
        format.html { redirect_to(@group, :notice => 'Group was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end

  private

  def send_group_announcement(g)
    user_list = User.near(g,$SEARCH_RANGE)
    user_list.each do |u|
      if !u.nil? && u.notify
        UserMailer.newgroup(g,u).deliver
      end
    end
  end

  def require_mst_or_owner
    if current_user.nil?
      return false
    end
    if current_user.login == 'mstoth'
        return true
    end
    g=Group.find(params[:id])
    if current_user.groups.include? g
      return true
    end
    render '/agent/error', :notice=>"You do not have permission."
    return false
  end

  def require_not_guest
    unless current_user.nil?
      if current_user.login[0..4]=="Guest"
        render '/agent/error', :notice=>"You do not have permission as a Guest."
        return false
      end
      return true
    end
    return false

  end

  private

  def user_params
    params.require(:group).permit(:image,:title,:contact,:phone,:street1,:street2,:city,:state,:zip,:website,:email,:locked, :display)
  end


end
