class PicturesController < ApplicationController
  def index
    @pictures = Picture.find(:all)#facebook_user.pictures

  end
  
  def capture    
    File.open(RAILS_ROOT + '/public/image.png', "wb") do |f|
      f << request.raw_post
    end
  end
  
  def create
    @picture = Picture.new(params[:picture])
    if @picture.save!
      redirect_to home_url
    end
  end
end