class Picture < ActiveRecord::Base
  has_attachment :storage => :s3, :content_type => :image
  validates_as_attachment                 
end
