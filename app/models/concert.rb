class Concert < ActiveRecord::Base
  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  extend SimpleCalendar
  has_many :pieces, dependent: :destroy
  has_many :reviews, dependent: :destroy

  geocoded_by :zip
  after_validation :geocode

  # def address
  #   self.zip
  # end

  # reverse_geocoded_by :latitude, :longitude
  # after_validation :reverse_geocode

  validates_presence_of :zip, :title, :genre
  #  validates_format_of :webpage,
  #  :message => "must be a valid URL",
  #  :with => /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?\z/ix
  validates_format_of :zip,
  :message => "5 or 9-digit zip code is needed",
  :with => /\A[0-9]{5}(\-[0-9]{4})?\z/


  def length
    mtotal=0
    stotal=0
    self.pieces.each do |p|
      d=p.duration.split(":")
      mtotal+=d[0].to_i
      stotal+=d[1].to_i
    end
    mtotal += stotal / 60
    stotal = stotal % 60
    [mtotal,stotal]
  end

  def create_address
    if !self.venue_id.nil?
      @venue = Venue.find(self.venue_id)
      self.address = [@venue.street1, @venue.street2, @venue.city, @venue.state, @venue.zip].join(", ")
    else
      if defined?(current_user)
        self.address = [current_user.city, current_user.state, current_user.zip].join(", ")
      end
    end
  end

  def start_time
    self.date
  end


end
