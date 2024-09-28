class Venue < ActiveRecord::Base

  acts_as_mappable :lat_column_name => :latitude,
                   :lng_column_name => :longitude


  # has_attached_file :vpic,
  #                   :storage => :s3,
  #                   :s3_region => 'us-east-1',
  #                   :s3_host_name => 's3.amazonaws.com',
  #                   :url =>':s3_domain_url',
  #                   :styles => { :medium => "300x300>", :thumb => "100x100>" },
  #                   :s3_credentials => "#{Rails.root}/config/s3.yml",
  #                   :s3_permissions => "public-read",
  #                   :path => ":style/:id/:filename"

  has_one_attached :image

 # validates_attachment :vpic, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }


  geocoded_by :address
  after_validation :geocode

  validates_format_of :phone,
  :message => "must be a valid telephone number.",
  :with => /\A[\(\)0-9\- \+\.]{10,20}\z/

  validates_format_of :zip,
  :message => "5 or 9-digit zip code is needed",
  :with => /\A[0-9]{5}(\-[0-9]{4})?\z/

  validates_format_of :website, :with =>
  /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?\z/ix

  validates_presence_of  :phone, :zip, :street1, :city, :state, :zip, :name, :email, :website, :contact



  def create_address
    self.address = [self.street1,self.city,self.state,self.zip].join(', ')
  end


end
