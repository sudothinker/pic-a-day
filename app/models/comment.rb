class Comment < ActiveRecord::Base
  belongs_to :picture
  validates_presence_of :fb_user_id, :on => :create, :message => "can't be blank"
  validates_presence_of :picture_id, :on => :create, :message => "can't be blank"
  validates_presence_of :text,       :on => :create, :message => "Please enter a comment"
  
  def story
    story = Facebooker::Feed::Action.new
    story.title = "<fb:name uid=\"#{self.fb_user_id}\" useyou=\"false\" capitalize=\"true\" /> commented on <fb:name uid=\"#{self.picture.fb_user_id}\" useyou=\"false\" capitalize=\"true\" />'s picture"
    story.image_1 = self.thumb.authenticated_s3_url
    story.image_1_link = "http://apps.facebook.com/apictureeveryday/pictures/#{self.id}"
    story.body = self.text
    story
  end
end
