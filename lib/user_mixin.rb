require 'digest/sha1'

module Facebooker
  # Holds attributes and behavior for a Facebook User
  class User
    def self.generate_hash(user_id)
      Digest::SHA1.hexdigest("--#{user_id}--70e167fcbe5217ea2250b552d13a4f675a6a4993--")
    end
    
    def self.set_profile_fbml!(user_id, picture)
      fbml = <<-FBML
        <div class="profile-container" style="width:280px; padding:20px; background-color:#e4e4e4; margin:5px auto;">
          <a style="display:block" href="http://apps.facebook.com/apicaday/"><img src="#{picture.profile.authenticated_s3_url}" alt="Me" style="margin-bottom:20px; display:block;" /></a>
          <div class="picture-info" style="font-size:14px; text-align:center;">
            #{picture.created_at.strftime('%B %d, %Y at %I:%M%p')}
          </div>
        </div>
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