class RootTableContentsController < ApplicationController

  include RootTable::ActionController

  before_filter :find_object_by_id

  def index
    @collection = model.all
  end

  def new
    @object = model.new
  end

  def create
    @object = model.new(params[table.underscore])
    if @object.save
      flash[:notice] = flash_messange(:created)
      redirect_to root_table_root_table_contents_url(table)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @object.update_attributes(params[table.underscore])
      flash[:notice] = flash_message(:updated)
      redirect_to root_table_root_table_contents_url(table)
    else
      render :edit
    end
  end

  def destroy
    @object.destroy
    flash[:notice] = flash_message(:destroyed)
    redirect_to root_table_root_table_contents_url(table)
  end

  def sort
    params[table.underscore].each_with_index do |id, index|
      model.update_all(["#{root_table.order}=?", index+1], ['id=?', id])
    end
    render :nothing => true
  end


end
