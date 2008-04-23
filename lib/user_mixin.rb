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
        <img src="#{picture.profile.authenticated_s3_url}" alt="Me" />
      FBML
      parameters[:profile] = fbml
      Session.current.post('facebook.profile.setFBML', parameters)
    end
  end
end