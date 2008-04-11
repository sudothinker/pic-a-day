require 'digest/sha1'
class PicturesController < ApplicationController
  def index
    @pictures = Picture.find(:all)#facebook_user.pictures
    @user_hash = Digest::SHA1.hexdigest("--id--OUR SECRET--") # replace with facebook_user.id
  end
  
  def capture   
    split = request.raw_post.split("|", 3)
    
    fb_user_id = split[0].to_i
    user_hash = split[1]
    
    # verify_the_hash
    return false unless user_hash == Digest::SHA1.hexdigest("--id--OUR SECRET--")
    
    File.open(RAILS_ROOT + '/public/image.png', "wb") do |f|
      f << split[2]
    end
  end
  
  def create
    @picture = Picture.new(params[:picture])
    if @picture.save!
      redirect_to home_url
    end
  end
end