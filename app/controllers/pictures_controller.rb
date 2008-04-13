require 'base64'
class PicturesController < ApplicationController
  # Suppresses image binary data from logger, Perhaps slice! would be faster
  filter_parameter_logging { |k,v| k.gsub!(/./, "") if k =~ /\|/i } 
  before_filter :find_picture_strip
    
  def index
    @last_picture = Picture.find(:first, :conditions => "thumbnail IS NULL", :order => "id DESC")
    redirect_to picture_path(@last_picture) if @last_picture && @last_picture.created_at >= Time.now - 1.day
    @user_hash = Facebooker::User.generate_hash(1234)# replace with User.generate_hash(facebook_user.id)
  end
  
  def show
    @picture = Picture.find(params[:id])
  end
  
  def capture
    fb_user_id, user_hash, encoded_png = request.raw_post.split("|", 3)
    redirect_to home_url and return false unless user_hash == Facebooker::User.generate_hash(fb_user_id)
    if Picture.create_from_png_data_and_fb_user_id(Base64.decode64(encoded_png), fb_user_id)
      #render :update do |page|
      #  page.replace_html :picture_strip, render(:partial => 'pictures', :locals => {:pictures => @pictures})
      #end
      redirect_to home_url
    end
  end
  
  def destroy
    @picture = Picture.find(params[:id])
    @picture.destroy
    redirect_to home_url
  end
  
  protected
    def find_picture_strip
      @pictures = Picture.paginate_all_by_thumbnail('thumb', :page => params[:page], :per_page => 6)#and_fb_user_id
    end
end