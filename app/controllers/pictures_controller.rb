require 'digest/sha1'
require 'base64'

class PicturesController < ApplicationController
  def index
    @pictures = Picture.find(:all)#facebook_user.pictures
    @user_hash = Digest::SHA1.hexdigest("--2--OUR SECRET--") # replace with facebook_user.id
  end
  
  def capture   
    fb_user_id, user_hash, encoded_png = request.raw_post.split("|", 3)
    redirect_to home_url and return false unless user_hash == Digest::SHA1.hexdigest("--#{fb_user_id}--OUR SECRET--")
    
    filename = RAILS_ROOT + "/tmp/attachment_fu/#{fb_user_id}_temp.png"
    File.open(filename, "wb") do |f|
      f << Base64.decode64(encoded_png)
    end
    
    # Save the record
    
    File.rm(filename)
    redirect_to home_url
  end
  
  def create
    @picture = Picture.new(params[:picture])
    if @picture.save!
      redirect_to home_url
    end
  end
end