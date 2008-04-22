# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper  
  def render_pictures(pictures)
    render :partial => "pictures", :locals => {:pictures => pictures}
  end
  
end
