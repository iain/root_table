class RootTable::TablesController < ApplicationController

  def index
    @tables = [ :category ]
  end

end
