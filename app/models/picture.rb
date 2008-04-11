class Picture < ActiveRecord::Base
  has_attachment :storage => :s3, :content_type => :image, 
                 :s3_access => :authenticated_read,
                 :thumbnails => {:thumb => '80x60', :profile => '360x270', :full => '480x360'}
  validates_as_attachment                 
end
