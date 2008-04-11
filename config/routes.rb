ActionController::Routing::Routes.draw do |map|
  #map.with_options :conditions => {:canvas => true} do |c|
  map.home '', :controller => "pictures"
  #end
  map.capture '/capture', :controller => "pictures", :action => "capture"
  map.resources :pictures
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
