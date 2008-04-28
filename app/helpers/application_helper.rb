# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper  
  def render_pictures(pictures, current_picture=nil)
    render :partial => "pictures", :locals => {:pictures => pictures, :picture => current_picture}
  end
  
  
  # Instructions are based on total pictures taken and whether picture has been taken today or not
  def display_instructions(pictures, taken_today = false)
    return if pictures.nil?
    default = "Take one picture of yourself each day, every day - like #{link_to "this", "http://youtube.com/watch?v=6B26asyGKDo"}."
    come_back = "Come back tomorrow, and take another picture of yourself."
    more_options = "More options will be available after you've taken a few more pictures."
    
    case pictures.size
    when 0
      default
    when 1..2
      taken_today ? come_back : default
    when 3..4
      more_options if taken_today
    else
      nil
    end
  end
  
end
