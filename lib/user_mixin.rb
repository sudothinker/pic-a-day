require 'digest/sha1'

module Facebooker
  # Holds attributes and behavior for a Facebook User
  class User
    def self.generate_hash(user_id)
      Digest::SHA1.hexdigest("--#{user_id}--70e167fcbe5217ea2250b552d13a4f675a6a4993--")
    end
    
    def self.set_profile_fbml!(user_id, picture)
      puts "Updating fbml for #{user_id}"
      parameters = {:uid => user_id}
      fbml = <<-FBML
        <div class="profile-container" style="width:360px; padding:10px 10px 20px 10px; background-color:#e4e4e4;">
          <img src="#{picture.profile.authenticated_s3_url}" alt="Me" style="width:360px; height:270px; margin-bottom:20px; display:block;" />
          <div class="picture-info" style="font-size:14px; text-align:center;">
            Taken #{picture.created_at.strftime('%B %d, %Y')} at #{picture.created_at.strftime('%I:%M%p')}
          </div>
        </div>
      FBML
      parameters[:profile] = fbml
      Session.current.post('facebook.profile.setFBML', parameters)
    end
  end
end