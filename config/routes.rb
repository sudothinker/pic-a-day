ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'pictures' do |f|
    f.home ''
    f.capture '/capture', :action => "capture"
  end
  
  map.facebook_resources :pictures
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
