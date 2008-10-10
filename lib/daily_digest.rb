pictures = Picture.find(:all, :conditions => ["thumbnail IS NULL AND created_at > ?", 1.day.ago])
Notifier.deliver_daily_digest(pictures)