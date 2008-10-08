class PicadayPublisher < Facebooker::Rails::Publisher
  # Action is published using the session of the from user
  def action(f)
    send_as :action
    from f
    title %(<fb:name uid="#{f.id}" useyou="false" capitalize="true" /> took a picture of #{f.sex == 'male' ? 'him' : 'her'}self today)
    body link_to("Take a picture of yourself with your webcam today", "http://apps.facebook.com/apictureeveryday")
  end
end