require 'base64'

class PicturesController < ApplicationController
  def index
    @pictures = Picture.paginate_all_by_thumbnail('thumb', :page => params[:page], :per_page => 7)#and_fb_user_id
    @user_hash = Facebooker::User.generate_hash(1234)# replace with User.generate_hash(facebook_user.id)
  end
  
  def capture   
    fb_user_id, user_hash, encoded_png = request.raw_post.split("|", 3)
    redirect_to home_url and return false unless user_hash == Facebooker::User.generate_hash(fb_user_id)
    
    if Picture.create_from_png_data_and_fb_user_id(Base64.decode64(encoded_png), fb_user_id)
      redirect_to home_url
    end
  end
end