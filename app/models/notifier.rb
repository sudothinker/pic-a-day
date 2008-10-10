class Notifier < ActionMailer::Base
  def daily_digest(pictures)
    @recipients = "mdmurray@gmail.com"
    @from       = 'Picaday <noreply@apictureeveryday.com>'
    @subject    = "Pic a day Daily Digest: #{pictures.size} pictures"
    @sent_on    = Time.now
    @content_type = "text/html"
    @body = {:pictures => pictures}
  end
end