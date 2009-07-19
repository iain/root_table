ActionController::Routing::Routes.draw do |map|
  map.resources :root_tables, :only => :index do |p|
    p.resources :manage, :collection => {:sort => :post}
  end
end
