# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper  
  def render_pictures(pictures, current_picture=nil)
    render :partial => "pictures", :locals => {:pictures => pictures, :picture => current_picture}
  end
  
  
  # Instructions are based on total pictures taken and whether picture has been taken today or not
  def display_instructions(pictures, taken_today = false)
    return if pictures.nil?
    
    default = "#{youtube_dialog}Take a picture of yourself each day, every day - like <a href=\"#\" clicktoshowdialog=\"youtube\" title=\"Click to view\">this</a>."
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
  
  def youtube_dialog
    <<-FBML
     <fb:dialog id="youtube" cancel_button=1>
        <fb:dialog-title>Noah takes a photo of himself every day for 6 years.</fb:dialog-title>
        <fb:dialog-content>
          <center>#{youtube_video}</center>
        </fb:dialog-content>
      </fb:dialog>
    FBML
  end
  
  def youtube_video
    <<-FBML
      <fb:swf swfbgcolor="000000" 
              imgstyle="border-width:3px; 
              border-color:white;" 
              swfsrc='http://www.youtube.com/v/6B26asyGKDo"/>' 
              imgsrc='http://img.youtube.com/vi/6B26asyGKDo/2.jpg' width='340' height='270' />     
    FBML
  end
end
