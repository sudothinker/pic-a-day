ActionController::Routing::Routes.draw do |map|
  map.with_options :conditions => {:canvas => true} do |c|
    
    c.with_options :controller => 'pictures' do |f|
      f.home ''
      f.destroy_picture '/pictures/destroy/:id', :action => 'destroy'
      f.invite '/invite', :action => "invite"
      f.upload '/upload', :action => 'upload'
    end
  end
  
  map.create_picture '/create', :controller => "pictures", :action => "create"
  map.connect '/redirector', :controller => 'pictures', :action => 'redirector'
  map.connect '/capture_saved', :controller => 'pictures', :action => 'capture_saved'
  map.capture '/capture', :action => "capture", :controller => "pictures"
  map.resources :pictures
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
