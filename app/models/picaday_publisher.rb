class PicadayPublisher < Facebooker::Rails::Publisher
  # Action is published using the session of the from user
=begin
  def action(f)
    send_as :story
    from f
    title %(<fb:name uid="#{f.id}" useyou="false" capitalize="true" /> took a picture of #{f.sex == 'male' ? 'him' : 'her'}self today)
    body link_to("Take a picture of yourself with your webcam today", "http://apps.facebook.com/apictureeveryday")
  end

  def templatized_news_feed(user, picture)
    send_as :templatized_action
    from(user)
    title_template %({actor} took a <a href="http://apps.facebook.com/apictureeveryday/pictures/{picture}">picture</a> today. <a href="http://apps.facebook.com/apictureeveryday">Take yours</a>.)
    title_data :picture => picture.id
    body_template("")#link_to("Take a picture of yourself with your webcam today", "http://apps.facebook.com/apictureeveryday"))
    body_general("")#link_to("Take a picture of yourself with your webcam today", "http://apps.facebook.com/apictureeveryday"))
    body_data(Hash.new())
    image_1(picture.thumb.authenticated_s3_url)
    image_1_link("http://apps.facebook.com/apictureeveryday/pictures/#{picture.id}")
  end
=end    
  def publish_action(f, picture)
    send_as :user_action
    from f
    #data :images => [{:src => picture.authenticated_s3_url, :href => "http://apps.facebook.com/apictureeveryday/pictures/#{picture.id}"}], :picture => picture.id
    
    data(:images => [{:src => picture.authenticated_s3_url, :href => "http://apps.facebook.com/apictureeveryday/pictures/#{picture.id}"}],
         :take_yours => %(<a href="http://apps.facebook.com/apictureeveryday">Take yours</a>),
         :picture => "http://apps.facebook.com/apictureeveryday/pictures/#{picture.id}")    
  end


           
  def publish_action_template
    one_line_story_template "{*actor*} took a {*picture*} today. {*take_yours*}."
    short_story_template "{*actor*} took a {*picture*} today. {*take_yours*}.", ""
    
    #one_line_story_template %({*actor*} took a <a href="http://apps.facebook.com/apictureeveryday/pictures/{*picture*}">picture</a> today. <a href="http://apps.facebook.com/apictureeveryday">Take yours</a>.)
    #short_story_template %({*actor*} joined the <a href="http://www.howcast.com/">Howcast</a> community.), %()
  end  
end