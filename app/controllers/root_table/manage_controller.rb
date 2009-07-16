class RootTable::ManageController < ApplicationController

  layout 'categories'

  def index
    @collection = model.all
  end

  def new
    @object = model.new
  end

  def create
    @object = model.new(params[table])
    if @object.save
      flash[:notice] = "#{model.human_name} saved"
      redirect_to root_table_table_manage_index_url(table)
    else
      render :new
    end
  end

  def edit
    @object = model.find(params[:id])
  end

  def update
    @object = model.find(params[:id])
    if @object.update_attributes(params[table])
      flash[:notice] = "#{model.human_name} saved"
      redirect_to root_table_table_manage_index_url(table)
    else
      render :edit
    end
  end

  protected

  def table
    @table ||= params[:table_id]
  end
  helper_method :table

  def model
    @model ||= table.to_s.camelize.constantize
  end
  helper_method :model

  def columns
    @columns ||= model.column_names - %w[ id updated_at created_at ]
  end
  helper_method :columns

end
