class Picture < ActiveRecord::Base
  has_attachment :storage => :s3,
                 :content_type => :image,
                 :s3_access => :authenticated_read,
                 :thumbnails => {:thumb => '80x60', :profile => '360x270'}
  validates_as_attachment      
  
  validate :validates_one_picture_per_day
  
  def self.create_from_png_data_and_fb_user_id(png_data, fb_user_id)
    filename = RAILS_ROOT + "/tmp/attachment_fu/#{fb_user_id}_temp.png"
    File.open(filename, "wb") do |f|
      f << png_data
    end

    # Save the record
    p = self.new
    p.fb_user_id = fb_user_id
    p.content_type = 'image/png'
    p.filename = "#{fb_user_id}_#{Date.today.strftime('%m_%d_%Y')}.png"
    p.temp_data=File.read(filename)
    File.delete(filename)
    return p.save
  end
  
  def taken_today?
    created_at.to_date == Date.today
  end
  
  def self.already_taken_today?(fb_user_id)
    last_pic = find(:first, :conditions => ['fb_user_id = ?', fb_user_id], :order => 'id DESC')
    last_pic && last_pic.taken_today?
  end
  
  protected
    def validates_one_picture_per_day
      self.errors.add(:fb_user_id, 'Only one picture allowed per day') if self.class.already_taken_today?(self.fb_user_id)
      return self.errors.empty?
    end
end
