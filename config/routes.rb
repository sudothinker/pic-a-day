ActionController::Routing::Routes.draw do |map|
  map.with_options :conditions => {:canvas => true} do |c|
    
    c.destroy_picture '/pictures/destroy/:id', :controller => 'pictures', :action => 'destroy'
    c.invite '/invite', :controller => "pictures", :action => "invite"
    c.with_options :controller => 'pictures' do |f|
      f.home ''
      f.capture '/capture', :action => "capture"
    end
  end
  
  map.camera '/camera', :controller => 'pictures', :action => 'camera'
  map.resources :pictures
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
