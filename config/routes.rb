ActionController::Routing::Routes.draw do |map|
  map.with_options :conditions => {:canvas => true} do |c|
    c.with_options :controller => 'pictures' do |f|
      f.home ''
      f.capture '/capture', :action => "capture"    
    end
    c.resources :pictures
  end
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
