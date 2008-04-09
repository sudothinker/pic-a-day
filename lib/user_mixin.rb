module Facebooker
  # Holds attributes and behavior for a Facebook User
  class User
    def pictures
      Picture.find_all_by_fb_user_id(self.id)
    end
  end
end