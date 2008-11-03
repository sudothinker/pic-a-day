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
  
  def publish_comment(f, comment)
    send_as :user_action
    from f
    data(:images => [{:src => comment.picture.authenticated_s3_url, :href => "http://apps.facebook.com/apictureeveryday/pictures/#{comment.picture.id}"}],
         :comment => comment.text,
         :picture => %(<a href="http://apps.facebook.com/apictureeveryday/pictures/#{comment.picture.id}">picture</a>),
         :owner => %(<fb:name uid="#{comment.picture.fb_user_id}" capitalize="true" useyou="false" />))
  end
  
  def publish_comment_template
    one_line_story_template %({*actor*} commented on {*owner*}'s {*picture*}.)
    short_story_template %({*actor*} commented on {*owner*}'s {*picture*}.), "{*actor*} said: <b>{*comment*}</b>"
  end
end