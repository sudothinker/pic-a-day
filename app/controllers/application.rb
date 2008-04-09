# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'e05a0ec6beed23fe8c5eee2dc035f455'
  
  #before_filter :ensure_application_is_installed_by_facebook_user
  
  helper_method :facebook_user
  def facebook_user
    @facebook_user ||= (session[:facebook_session] && session[:facebook_session].user) || :false
  end
end
