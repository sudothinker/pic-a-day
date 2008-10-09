class PicadayPublisher < Facebooker::Rails::Publisher
  # Action is published using the session of the from user
  def action(f)
    send_as :story
    from f
    title %(<fb:name uid="#{f.id}" useyou="false" capitalize="true" /> took a picture of #{f.sex == 'male' ? 'him' : 'her'}self today)
    body link_to("Take a picture of yourself with your webcam today", "http://apps.facebook.com/apictureeveryday")
  end
  
  def templatized_news_feed(user, picture)
    send_as :templatized_action
    from(user)
    title_template "{actor} took a picture of themself today."
    title_data(:actor => user.name)
    body_template("")
    body_general(link_to("Take a picture of yourself with your webcam today", "http://apps.facebook.com/apictureeveryday"))
    body_data(Hash.new())
    image_1(picture.thumb.authenticated_s3_url)
    image_1_link("http://apps.facebook.com/apictureeveryday/pictures/#{picture.id}")
  end
end