require 'digest/sha1'

module Facebooker
  # Holds attributes and behavior for a Facebook User
  class User
    def self_or_in_friends?(user_id)
      self.id == user_id || self.friends.map(&:id).include?(user_id)
    end
    
    def self.generate_hash(user_id)
      Digest::SHA1.hexdigest("--#{user_id}--70e167fcbe5217ea2250b552d13a4f675a6a4993--")
    end
    
    def self.set_profile_fbml!(user_id, picture)
      fbml = <<-FBML
      <style type="text/css" media="screen">
        div.profile-wide { width:280px; padding:20px; background-color:#e4e4e4; margin:5px auto; }
        div.profile-wide a { display:block; }
        div.profile-wide a img { display:block; }
        div.profile-wide a.profile img { margin-bottom:20px; width:280px; height:210px; }
        div.profile-wide div.picture-info { font-size:14px; text-align:center; }

        div.profile-narrow { width:128px; padding:10px; background-color:#e4e4e4; margin:5px auto; }
        div.profile-narrow a { display:block; }
        div.profile-narrow a img { display:block; }
        div.profile-narrow a.thumb img { margin-bottom:10px; width:128px; height:96px; }
        div.profile-narrow div.picture-info { font-size:10px; text-align:center; }
      </style>
      <fb:wide>
        <div class="profile-wide">
          <a class="profile" href="http://apps.facebook.com/apictureeverydaystag/pictures/#{picture.id}"><img src="#{picture.profile.authenticated_s3_url}" /></a>
          <div class="picture-info">
            #{picture.created_at.strftime('%B %d, %Y at %I:%M%p')}
          </div>
        </div>
      </fb:wide>
      <fb:narrow>
        <div class="profile-narrow">
          <a class="thumb" href="http://apps.facebook.com/apictureeverydaystag/pictures/#{picture.id}"><img src="#{picture.narrow.authenticated_s3_url}" /></a>
          <div class="picture-info">
            #{picture.created_at.strftime('%B %d, %Y')}
          </div>
        </div>
      </fb:narrow>
      FBML
      update_profile_fbml!(user_id, fbml)
    end
    
    def self.update_profile_fbml!(user_id, fbml)
      puts "Updating fbml for #{user_id}"
      parameters = {:uid => user_id}
      parameters[:profile] = fbml
      Session.current.post('facebook.profile.setFBML', parameters)
    end
  end
end