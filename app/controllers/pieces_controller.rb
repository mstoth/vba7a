class PiecesController < ApplicationController
  before_action :set_piece, only: %i[ show edit update destroy ]
  before_action  :check_if_stale
  
  def check_if_stale
    if current_user_session.stale? or current_user_session.nil?
      redirect_to '/user_sessions/new', :notice => 'Your session has timed out, please log in.'
    end
  end

  # GET /pieces or /pieces.json
  def index
    @concerts = current_user.my_concerts
    @pieces = []
    @concerts.each do |concert|
      concert.pieces.each do |p|
        puts p.title
        @pieces << p
      end
    end
  end

  # GET /pieces/1 or /pieces/1.json
  def show
    if Concert.where(id: @piece.concert_id).empty?
      @dummy = Concert.find_by(title: "Dummy")
      @piece.id = @dummy.id
      @piece.save
    end
  end

  # GET /pieces/new
  def new
    @concerts = Concert.all()
    @piece = Piece.new
  end

  def add
    if params[:pid].nil? 
      puts "PID WAS NIL"
      @piece = Piece.new
    else
      @piece = Piece.find_by :id=>:pid
    end
    
    @concert = Concert.find(params[:id])
    @concerts = Concert.all()
    @dummy=Concert.find_by(:title=>"Dummy")
    if @dummy.nil?
      @dummypieces=[]
    else
      @dummypieces = Piece.find_by :concert_id=>@dummy.id
    end
    if @dummypieces.class == Piece
      @dummypieces = [@dummypieces]
    end
  end

  def remove
    @dummy = Concert.find_by :title=>"Dummy"
    if @dummy.nil?
      @dummy=Concert.new(:title=>"Dummy")
      @dummy.genre="save"
      @dummy.zip=@current_user.zip
      @dummy.save
    end
    
    @piece = Piece.find_by :id=>params[:id]
    puts "piece is #{@piece.title}"
    @concert = Concert.find_by :id=>@piece.concert_id
    @piece.concert_id = @dummy.id
    if @piece.save
      puts "Piece was saved"
    end
  end
    

  # GET /pieces/1/edit
  def edit
    @concerts = Concert.all()
    @dummy = Concert.find_by :title=>"Dummy"
    if @dummy.nil?
      @dummypieces=[]
    else
      @dummypieces = Piece.find_by :concert_id=>@dummy.id
    end
    if @dummypieces.nil? 
      @dummypieces=[]
    end
    if @dummypieces.class == Piece
      @dummypieces = [@dummypieces]
    end
  end

  # POST /pieces or /pieces.json
  def create
    puts piece_params
    @piece = Piece.new(piece_params)
    puts params["concert_id"]

    @concerts = Concert.all()
    respond_to do |format|
      if @piece.save
        format.html { redirect_to @piece, notice: "Piece was successfully created." }
        format.json { render :show, status: :created, location: @piece }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @piece.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pieces/1 or /pieces/1.json
  def update
    @concerts = Concert.all()
    @piece.concert_id = params["concert_id"]
    puts piece_params
    respond_to do |format|
      if @piece.update(piece_params)
        format.html { redirect_to @piece, notice: "Piece was successfully updated." }
        format.json { render :show, status: :ok, location: @piece }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @piece.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pieces/1 or /pieces/1.json
  def destroy
    @piece.destroy
    respond_to do |format|
      format.html { redirect_to pieces_url, notice: "Piece was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_piece
      @piece = Piece.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def piece_params
      params.require(:piece).permit(:title, :composer, :songtype, :duration, :recording, :concert_id)
    end
end
