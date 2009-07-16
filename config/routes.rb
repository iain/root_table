ActionController::Routing::Routes.draw do |map|
  map.namespace :root_table do |root_table|
    root_table.resources :tables, :only => :index do |r|
      r.resources :manage, :except => :show
    end
  end
end
