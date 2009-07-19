ActionController::Routing::Routes.draw do |map|
  map.resources :root_tables, :only => :index do |p|
    p.resources :root_table_contents, :collection => {:sort => :post}, :as => "contents"
  end
end
