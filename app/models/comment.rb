class Comment < ActiveRecord::Base
  belongs_to :picture
  validates_presence_of :fb_user_id, :on => :create, :message => "can't be blank"
  validates_presence_of :picture_id, :on => :create, :message => "can't be blank"
  validates_presence_of :text,       :on => :create, :message => "Please enter a comment"
end
