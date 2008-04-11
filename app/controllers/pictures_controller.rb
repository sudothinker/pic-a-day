require 'digest/sha1'
require 'base64'

class PicturesController < ApplicationController
  
  filter_parameter_logging { |k,v| k.gsub!(/./, "") if k =~ /\|/i } # Suppresses image binary data from logger 
                                                                    # Perhaps slice! would be faster
    
  def index
    @pictures = Picture.find_all_by_thumbnail('thumb')#facebook_user.pictures
    @user_hash = Digest::SHA1.hexdigest("--2--OUR SECRET--") # replace with facebook_user.id
  end
  
  def capture
    fb_user_id, user_hash, encoded_png = request.raw_post.split("|", 3)
    redirect_to home_url and return false unless user_hash == Digest::SHA1.hexdigest("--#{fb_user_id}--OUR SECRET--")

    if Picture.create_from_png_data_and_fb_user_id(Base64.decode64(encoded_png), fb_user_id)
      redirect_to home_url
    end
  end
  
  def create
    @picture = Picture.new(params[:picture])
    if @picture.save!
      redirect_to home_url
    end
  end
end