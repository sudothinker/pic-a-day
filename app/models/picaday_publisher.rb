class PicadayPublisher < Facebooker::Rails::Publisher 
  def publish_action(f, picture)
    send_as :user_action
    from f
    data(:images => [{:src => picture.authenticated_s3_url, :href => "http://apps.facebook.com/apictureeveryday/pictures/#{picture.id}"}],
         :take_yours => %(<a href="http://apps.facebook.com/apictureeveryday">Take yours</a>),
         :picture => %(<a href="http://apps.facebook.com/apictureeveryday/pictures/#{picture.id}">picture</a>))    
  end
           
  def publish_action_template
    one_line_story_template "{*actor*} took a {*picture*} today. {*take_yours*}."
    short_story_template "{*actor*} took a {*picture*} today. {*take_yours*}.", ""
  end  
end