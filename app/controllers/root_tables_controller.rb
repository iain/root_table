class RootTablesController < ApplicationController
  unloadable

  def index
    @tables = ActiveRecord::Base.all_root_tables
  end

end
