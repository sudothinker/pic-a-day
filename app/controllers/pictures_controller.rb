require 'base64'
class PicturesController < ApplicationController
  # Suppresses image binary data from logger, Perhaps slice! would be faster
  filter_parameter_logging { |k,v| k.gsub!(/./, "") if k =~ /\|/i } 
  before_filter :find_picture_strip
  before_filter :find_picture, :only => [:show, :destroy]
  skip_before_filter :ensure_application_is_installed_by_facebook_user, :ensure_authenticated_to_facebook, :only => :capture
  
  def index
    @last_picture = Picture.find(:first, :conditions => ["fb_user_id = ? AND thumbnail IS NULL", facebook_user.id], :order => "id DESC")    
    redirect_to picture_path(@last_picture) if @last_picture && @last_picture.taken_today?
    @user_hash = Facebooker::User.generate_hash(facebook_user.id)
  end
  
  def show
  end
  
  def invite
  end
  
  def redirector
    redirect_to home_path
  end
  
  def capture
    fb_user_id, user_hash, encoded_png = request.raw_post.split("|", 3)
    return false unless user_hash == Facebooker::User.generate_hash(fb_user_id)
    picture = Picture.create_from_png_data_and_fb_user_id(Base64.decode64(encoded_png), fb_user_id)
    Facebooker::User.set_profile_fbml!(fb_user_id, picture)
  end
  
  def destroy
    @picture.destroy
    redirect_to home_path
  end
  
  protected
    def find_picture_strip
      @pictures = Picture.paginate_by_fb_user_id(facebook_user.id, :page => params[:page], :per_page => 6, :order => "id DESC")
    end
    
    def find_picture
      @picture = Picture.find(params[:id], :conditions => "parent_id IS NULL")
      redirect_to home_url and return false if @picture.nil? || @picture.fb_user_id != facebook_user.id
    end
end