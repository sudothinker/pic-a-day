require 'base64'
class PicturesController < ApplicationController
  # Suppresses image binary data from logger, Perhaps slice! would be faster
  filter_parameter_logging { |k,v| k.gsub!(/./, "") if k =~ /\|/i } 

  before_filter :find_picture, :only => [:show, :destroy]
  skip_before_filter :ensure_application_is_installed_by_facebook_user, :ensure_authenticated_to_facebook, :only => [:capture, :redirector]
  
  def index
    @last_picture = Picture.find(:first, :conditions => ["fb_user_id = ? AND thumbnail IS NULL", facebook_user.id], :order => "id DESC")    
    begin
      PicadayPublisher.deliver_templatized_news_feed(facebook_user, @last_picture) if params[:post_story]
    rescue Exception => exception
      ExceptionNotifier.deliver_exception_notification(exception, self, request)
    end
    redirect_to picture_path(@last_picture) if @last_picture && @last_picture.taken_today?
    @user_hash = Facebooker::User.generate_hash(facebook_user.id)
    @pictures = Picture.paginate_by_fb_user_id(facebook_user.id, :page => params[:page], :per_page => 6, :order => "id DESC")
  end
  
  def show
    @next_picture = Picture.find(:first, :conditions => ["fb_user_id = ? AND id > ?", @picture.fb_page_id || @picture.fb_user_id, params[:id]], :order => "id ASC")
    if @picture.fb_page_id
      @pictures = Picture.paginate(:conditions => ["fb_page_id = ?", @picture.fb_page_id], :page => params[:page], :per_page => 6, :order => "id DESC")
    else
      @pictures = Picture.paginate(:conditions => ["fb_user_id = ? AND fb_page_id IS NULL", @picture.fb_user_id], :page => params[:page], :per_page => 6, :order => "id DESC")
    end
  end
  
  def upload
    @picture = Picture.new
  end
  
  def create
    @picture = Picture.new params[:picture]
    fb_page_id = (params["fb_sig_is_admin"] == "1" && params["fb_sig_page_added"] == "1" && !params["fb_sig_page_id"].nil?) ? params["fb_sig_page_id"] : nil
    @picture.fb_user_id = facebook_user.id
    @picture.fb_page_id = fb_page_id
    if @picture.save
      Facebooker::User.set_profile_fbml!(@picture.fb_page_id || @picture.fb_user_id, @picture)
      redirect_to "http://apps.facebook.com/apictureeveryday/pictures/#{@picture.id}"
    else
      redirect_to "http://apps.facebook.com/apictureeveryday/"
    end
  end
  
  def capture_saved
    pic = Picture.find(:first, :conditions => ["id > ? AND fb_user_id = ?", params[:id], facebook_user.id], :order => "id DESC")    
    render :text => pic.nil? ? "FAIL" : 'SUCCESS'
  end
  
  def invite
  end
  
  def redirector
    redirect_to home_path(:post_story => true)
  end
  
  # fb_user_id + "|" + user_hash + "|" + fb_page_id + "|" + fb_sig_is_admin + "|" + fb_sig_page_added + "|" + Base64.encodeByteArray(png);
  def capture
    fb_user_id, user_hash, fb_page_id, fb_sig_is_admin, fb_sig_page_added, encoded_png = request.raw_post.split("|", 6)
    return false unless user_hash == Facebooker::User.generate_hash(fb_user_id)
    fb_page_id = (fb_sig_is_admin == "1" && fb_sig_page_added == "1" && !fb_page_id.blank?) ? fb_page_id : nil
    picture = Picture.create_from_png_data_and_fb_user_id(Base64.decode64(encoded_png), fb_page_id || fb_user_id)
    Facebooker::User.set_profile_fbml!(fb_page_id || fb_user_id, picture)
    render :nothing => true
  end
  
  def destroy
    if @picture.taken_today?
      last_picture = Picture.find(:first, :conditions => ["fb_user_id = ? AND thumbnail IS NULL AND id < ?", facebook_user.id, @picture.id], :order => "id DESC")
      default = <<-DEF
        <center><a href="http://apps.facebook.com/apictureeveryday"><img src="http://pseudothinker.com/images/koala.jpg" alt="A Picture Everyday" /></a></center>
      DEF
      last_picture.nil? ? Facebooker::User.update_profile_fbml!(facebook_user.id, default) : Facebooker::User.set_profile_fbml!(facebook_user.id, last_picture)
    end
    @picture.destroy
    redirect_to home_path
  end
  
  protected
    def find_picture
      @picture = Picture.find_with_deleted(params[:id], :conditions => "parent_id IS NULL")
      can_view_picture = !@picture.nil? && @picture.deleted_at.nil? && (facebook_user.self_or_in_friends?(@picture.fb_user_id) || !@picture.fb_page_id.nil?)
      redirect_to home_url and return false unless can_view_picture
    end
end