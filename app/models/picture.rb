class Picture < ActiveRecord::Base
  has_attachment :storage => :s3, :max_size => 200.kilobytes, :content_type => :image, 
                 :thumbnails => { :thumb => [50, 50], :geometry => 'x50' }
  validates_as_attachment                 
end
