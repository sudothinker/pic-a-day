class PicturesController < ApplicationController
  def index
    @pictures = Picture.find(:all)#facebook_user.pictures
  end
  
  def create
    @picture = Picture.new(params[:picture])
    if @picture.save!
      redirect_to home_url
    end
  end
end