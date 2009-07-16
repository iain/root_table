class RootTable::ManageController < ApplicationController

  before_filter :find_object_by_id

  def index
    @collection = model.all
  end

  def new
    @object = model.new
  end

  def sort
    params[table.underscore].each_with_index do |id, index|
      model.update_all(["#{root_table.order}=?", index+1], ['id=?', id])
    end
    render :nothing => true
  end

  def create
    @object = model.new(params[table.underscore])
    if @object.save
      flash[:notice] = I18n.t(:created, :table => model.human_name, :scope => :root_table)
      redirect_to root_table_table_manage_index_url(table)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @object.update_attributes(params[table.underscore])
      flash[:notice] = I18n.t(:updated, :table => model.human_name, :scope => :root_table)
      redirect_to root_table_table_manage_index_url(table)
    else
      render :edit
    end
  end

  def destroy
    @object.destroy
    flash[:notice] = I18n.t(:destroyed, :table => model.human_name, :scope => :root_table)
    redirect_to root_table_table_manage_index_url(table)
  end

  private

  def find_object_by_id
    @object = model.find(params[:id]) if params[:id]
  end

  def root_table
    ::ActiveRecord::Base.root_tables[table].first
  end
  helper_method :root_table

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
