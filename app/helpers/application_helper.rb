# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper  
  def render_pictures(pictures, current_picture=nil)
    render :partial => "pictures", :locals => {:pictures => pictures, :picture => current_picture}
  end
  
end
