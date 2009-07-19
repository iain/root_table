class RootTableContentsController < ApplicationController

  # This is where the magic happens:
  include RootTable::ActionController

  def index
    @collection = model.all
  end

  def new
    @object = model.new
    render_per_table :new
  end

  def create
    @object = model.new(params[table])
    if @object.save
      flash[:notice] = flash_messange(:created)
      redirect_to root_table_root_table_contents_url(table)
    else
      render_per_table :new
    end
  end

  def edit
    render_per_table :edit
  end

  def update
    if @object.update_attributes(params[table])
      flash[:notice] = flash_message(:updated)
      redirect_to root_table_root_table_contents_url(table)
    else
      render_per_table :edit
    end
  end

  def destroy
    @object.destroy
    flash[:notice] = flash_message(:destroyed)
    redirect_to root_table_root_table_contents_url(table)
  end

  def sort
    params[table].each_with_index do |id, index|
      model.update_all(["#{root_table.order}=?", index+1], ['id=?', id])
    end
    render :nothing => true
  end


end
