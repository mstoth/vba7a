class VenuesController < ApplicationController
  before_action  :require_not_guest, :except=>[:index, :show]
  before_action  :require_mst_or_owner, :only=>[:edit, :destroy, :update]
  before_action  :check_if_stale


  def check_if_stale
    if current_user_session.nil?
      redirect_to '/user_sessions/new', :notice => 'Your session has timed out, please log in.'
    else
      if current_user_session.stale?
        redirect_to '/user_sessions/new', :notice => 'Your session has timed out, please log in.'
      end
    end
  end

  # GET /venues
  # GET /venues.xml
  def index
    @venues = current_user.venues
    @venue_list = []
    @avail_venues = Venue.near(current_user,$SEARCH_RANGE)
    @avail_venues.each do |v|
      if v.user_id.nil?
        @venue_list << v
      end
    end
    @avail_venues = @venue_list
    if @avail_venues.is_a?(Array)
      @avail_venues.sort { |a,b| a.name <=> b.name }
    end
    if @venues.is_a?(Array)
      @venues.sort { |a,b| a.name <=> b.name }
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @venues }
    end
  end

  def concerts_near
    @genre = params[:genre]
    @venue = Venue.find(params[:id])

    if params["distance"].nil?
      @concerts = Concert.near(current_user,$SEARCH_RANGE).to_ary
      @concerts = @concerts.sort { |a,b| a.title <=> b.title }
      @current_dist = $SEARCH_RANGE
    else
      @concerts = Concert.near(current_user,params["distance"]).to_ary
      @concerts.sort { |a,b| a.title <=> b.title }
      @current_dist = params["distance"]
    end

    if @concerts.nil?
      @concerts=[]
    end

    @concert_list = []
    @concerts_booked = []
    @concerts.each do |c|
      if c.offer
          @concert_list << c
        else
          @concerts_booked << c
      end
    end
    @concerts = @concert_list

    @genres = ['All']
    @concerts.each do |c|
      if !(@genres.include? c.genre)
        @genres << c.genre unless c.genre.nil?
      end
    end
    @selected_concerts = []

    if @genre.nil? || @genre=='All'
      @concerts.each do |c|
        @selected_concerts << c
      end
    else
      @concerts.each do |c|
        if c.genre == @genre
          @selected_concerts << c
        end
      end
    end

    @my_venues = current_user.venues

  end

  # GET /venues/1
  # GET /venues/1.xml
  def show
    @venue = Venue.find(params[:id])
    @venue.create_address()
    @concerts = Concert.where(:venue_id=>@venue.id)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @venue }
    end
  end

  # GET /venues/new
  # GET /venues/new.xml
  def new
    @venue = Venue.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @venue }
    end
  end

  # GET /venues/1/edit
  def edit
    @venue = Venue.find(params[:id])
  end

  # POST /venues
  # POST /venues.xml
  def create
    @venue = Venue.new(user_params.to_h)
    @venue.create_address
    respond_to do |format|
      if @venue.save
        current_user.venues << @venue
        current_user.save
        format.html { redirect_to(@venue, :notice => 'Venue was successfully created.') }
        format.xml  { render :xml => @venue, :status => :created, :location => @venue }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @venue.errors, :status => :unprocessable_entity }
      end
    end
  end


  # PUT /venues/1
  # PUT /venues/1.xml
  def update
    @venue = Venue.find(params[:id])
    @venue.create_address
    respond_to do |format|
      if @venue.update(user_params.to_h)
        format.html { redirect_to(@venue, :notice => 'Venue was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @venue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /venues/1
  # DELETE /venues/1.xml
  def destroy
    @venue = Venue.find(params[:id])
    @venue.destroy

    respond_to do |format|
      format.html { redirect_to(venues_url) }
      format.xml  { head :ok }
    end
  end

  def slider

  end

  private

  def require_mst_or_owner
    if current_user.nil?
      return false
    end
    if current_user.login == 'mstoth'
        return true
    end
    venue=Venue.find(params[:id])
    if current_user.venues.include? venue
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
    params.require(:venue).permit(:image,:phone,:zip,:name,:email,:website,:contact,:street1,:city,:state,:street2,:display)
  end


end
