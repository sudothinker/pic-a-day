class Picture < ActiveRecord::Base
  has_attachment :storage => :s3, :content_type => :image, 
                 :s3_access => :authenticated_read,
                 :thumbnails => {:thumb => '10x10', :profile => 'x300'}
  validates_as_attachment                 
end
