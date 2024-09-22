class ReviewsController < ApplicationController
  before_action :set_review, only: %i[ show edit update destroy ] 
  before_action  :check_if_stale
  
  def check_if_stale
    if current_user_session.stale? or current_user_session.nil?
      redirect_to '/user_sessions/new', :notice => 'Your session has timed out, please log in.'
    end
  end


  # GET /reviews or /reviews.json
  def index
    @reviews = Review.all
  end

  # GET /reviews/1 or /reviews/1.json
  def show
  end

  # GET /reviews/new
  def new
    if params["cid"].nil? 
      flash[:notice] = "Can't find the concert id"
      redirect_to(concert_path(@concert.id))
      return
    end
    @concert = Concert.find(params["cid"])

    if !@concert.nil?
      if !@concert.date.nil? 
        if @concert.date < Date.today 
          flash[:notice] = "This concert hasn't been booked yet.  You need to choose a concert that was performed."
          redirect_to("/")
          return
        end
      end
    end

    @review = Review.new
    @author = current_user.login
    @user_id = current_user.id
    @concert_list = Concert.where(offer: false)
    tmp_list = []
    @concert_list.each do |c|
      if c.title=="Dummy" or c.reviews.nil? or c.date > Date.today
        # @concert_list.remove(c)
      else
        tmp_list << c
      end
    end
    @concert_list = tmp_list
    
    if @concert_list.empty? 
      flash[:notice] = "This concert hasn't been booked yet.  You need to choose a concert that was performed."
      redirect_to("/concerts/#{@concert.id}")
      return
    end
    if @concert.nil? or @concert.offer
      # replace the offer with one that has been played, can't make a review of an offer.
      @concert = @concert_list.first 
    end
    @previous_concerts = Concert.where("date < ?",Date.today)
    if @concert.nil? 
      flash[:notice] = "This concert hasn't been booked yet.  You need to choose a concert that was performed."
      redirect_to("/concerts")
      return
    end
    @concert_venue = Venue.find(@concert.venue_id)
    @performed_by = Group.find(@concert.group_id)
    @perform_time = @concert.date
    
  end

  
  # GET /reviews/1/edit
  def edit
  end

  # POST /reviews or /reviews.json
  def create
    @review = Review.new(review_params)
    @author = current_user.login 
    @user_id = current_user.id
    @review.stars = params["stars"]
    @review.user_id = current_user.id
    respond_to do |format|
      if @review.save
        format.html { redirect_to @review, notice: "Review was successfully created." }
        format.json { render :show, status: :created, location: @review }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reviews/1 or /reviews/1.json
  def update
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to @review, notice: "Review was successfully updated." }
        format.json { render :show, status: :ok, location: @review }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1 or /reviews/1.json
  def destroy
    @review.destroy
    respond_to do |format|
      format.html { redirect_to reviews_url, notice: "Review was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def require_mst_or_owner
    if current_user.nil? 
      return false
    end
    if current_user.login == 'mstoth'
        return true
    end
    return false
  end

    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def review_params
      params.require(:review).permit(:title, :stars, :comment, :concert_id, :venue_id, :user_id)
    end
  end
