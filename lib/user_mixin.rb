require 'digest/sha1'

module Facebooker
  # Holds attributes and behavior for a Facebook User
  class User
    def self.generate_hash(user_id)
      Digest::SHA1.hexdigest("--#{user_id}--70e167fcbe5217ea2250b552d13a4f675a6a4993--")
    end
  end
end