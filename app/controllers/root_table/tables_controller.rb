class RootTable::TablesController < ApplicationController

  before_filter :find_root_tables

  def index
  end

  private

  def find_root_tables
    Dir.glob(File.join(Rails.root, "app", "models", "**" "*.rb")).each { |f| require f }
    @tables = ActiveRecord::Base.root_tables || {}
  end

end
