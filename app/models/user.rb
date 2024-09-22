class User < ActiveRecord::Base
  letsrate_rater
  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude

  has_many :venues
  has_and_belongs_to_many :groups
  
  acts_as_authentic do |c| 
    c.crypto_provider = ::Authlogic::CryptoProviders::SCrypt 
  end 

  acts_as_authentic do |c|
    c.logged_in_timeout = 20.minutes # default is 10.minutes
  end
  
  geocoded_by :address
  after_validation :geocode

  
  # reverse_geocoded_by :latitude, :longitude
  # after_validation :reverse_geocode

  validates_presence_of :zip
  validates_uniqueness_of :login
  validates_presence_of :login
  validates_format_of :zip,
  :message => "5 or 9-digit zip code is needed",
  :with => /\A[0-9]{5}(\-[0-9]{4})?\z/

  
  def deliver_login!
    reset_perishable_token!
    UserMailer.login_name(self).deliver
  end
  
  
  def deliver_password_reset_instructions!
    reset_perishable_token!
    UserMailer.password_reset_instructions(self).deliver
  end

  def create_address
    self.address = [self.city, self.state, self.zip].join(", ")
  end
  
  def join_group
    id=params[:id]
    g=Group.find(id)
    self.groups << g
  end
    
  def personal_concerts()
    groups=self.groups
    @personal_concerts = []
    groups.each do |g|
      g.concerts.each do |c|
        if c.title == "Personal"
          @personal_concerts << c
        end
      end
    end
  end
  
  # if offer = true, returns non-booked concerts, i.e. offerings. 
  # if offer = false, returns booked concerts. 
  def my_concerts(offer=true)
    groups=self.groups
    @concerts = []
    groups.each do |g|
      g.concerts.each do |c|
        if c.offer==offer and c.title != "Personal"
          @concerts << c
        end
      end
    end
    if offer == false
      @concerts.sort! { |a,b| a.date <=> b.date }
    end
    @concerts
  end
end
