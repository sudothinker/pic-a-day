class Picture < ActiveRecord::Base
  has_attachment :storage => :s3, :content_type => :image, 
                 #:s3_access => :authenticated_read,
                 :thumbnails => {:thumb => '80x60', :profile => '360x270'}
  validates_as_attachment      
  
  def self.create_from_png_data_and_fb_user_id(png_data, fb_user_id)
    filename = RAILS_ROOT + "/tmp/attachment_fu/#{fb_user_id}_temp.png"
    File.open(filename, "wb") do |f|
      f << png_data
    end

    # Save the record
    p = self.new
    p.fb_user_id = fb_user_id
    p.content_type = 'image/png'
    p.filename = "#{Time.now.to_i}.png"
    p.temp_data=File.read(filename)
    File.delete(filename)
    return p.save
  end           
end
