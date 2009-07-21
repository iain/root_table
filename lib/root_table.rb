module RootTable

  module ActiveRecord

    attr_accessor :validations_for_root_table_added, :root_tables #:nodoc:

    # Define this model to be a root table for another model.
    #
    # Example:
    #
    #   class Product < ActiveRecord::Base
    #     # nothing ...
    #   end
    #
    #   class Category < ActiveRecord::Base
    #     root_table_for :product
    #   end
    #
    # In this example the *root* table is Category and the *target* model is
    # Product. Just so we're clear in what we're talking about.
    #
    # The configuration options are:
    #
    # * +field+ - Which field of the root table is the displayed value. The
    #   default is :name.
    # * +to+ - How is the relation called? On the target model you would
    #   normally say "belongs_to :foo, :foreign_key => "bar".
    #   Specify what :foo would be, if different from the convention.
    # * +foreign_key+ - Just as you would specify the foreign_key in the
    #   belongs_to relation, if different from the relation name.
    # * +order+ - Default order of the root table. Will be used for
    #   acts_as_list, if installed. Without acts_as_list, this defaults
    #   to :name (or whatever you set field to), with acts_as_list installed
    #   it will default to :position.
    # * +validate+ - Set to false to disable automatic validations. Defaults
    #   to validating presence and uniqueness of +field+
    # * +acts_as_list+ - Set to false if you have acts_as_list installed, but
    #   don't want to use it in this case.
    def root_table_for(target_name, options = {})
      root_table = RootTable.new(self, target_name, options)
      ::ActiveRecord::Base.root_tables ||= {}
      ::ActiveRecord::Base.root_tables[root_table.source_name] ||= []
      ::ActiveRecord::Base.root_tables[root_table.source_name] << root_table
      root_table.initialize_for_source
    end

    def has_root_table(source_name)
      model = source_name.to_s.camelize.constantize
      root_table = ::ActiveRecord::Base.root_tables[model.name].select { |rt| rt.target == self }.first
      root_table.initialize_for_target
    end

    # Returns all root tables found (in the app/models directory).
    # Used in the controller to build up a list for that.
    # Just generate a constant, so Rails will take care of the depency loading.
    def all_root_tables
      Dir.glob(File.join(Rails.root, "app", "models", "**" "*.rb")).each { |f| File.basename(f, ".rb").camelize.constantize }
      ::ActiveRecord::Base.root_tables || {}
    end

    class RootTable

      attr_reader :target_name, :options, :source

      def initialize(source, target_name, options)
        @source       = source
        @target_name  = target_name
        @options      = options
      end

      def initialize_for_source
        add_order
        add_validations if add_validations?
        add_relations
      end

      def initialize_for_target
        target.belongs_to(to.to_sym, :class_name => source_name, :foreign_key => foreign_key)
        target.delegate(field, :to => to, :prefix => true, :allow_nil => true)
        #raise "foo #{to.inspect} #{source_name}"
      end

      def add_order
        source.acts_as_list(:column => order) if acts_as_list?
        source.send(:default_scope, :order => order)
      end

      def add_validations
        source.validates_presence_of(field)
        source.validates_uniqueness_of(field)
        source.validations_for_root_table_added = true
      end

      def add_relations
        source.has_many(target_plural, :foreign_key => foreign_key)
      end

      def order
        return @order if @order
        if acts_as_list?
          @order = options[:order] || :position
        else
          @order = options[:order] || field
        end
      end

      def source_name
        @source_name ||= source.name
      end

      def field
        @field ||= options[:field] || :name
      end

      def to
        @to ||= options[:to] || source_name.underscore
      end

      def foreign_key
        @foreign_key ||= options[:foreign_key] || "#{to}_id"
      end

      def target
        @target ||= target_name.to_s.camelize.constantize
      end

      def target_plural
        @target_plural ||= target_name.to_s.pluralize.to_sym
      end

      def acts_as_list?
        return @acts_as_list if @acts_as_list
        installed     = ::ActiveRecord.const_defined?(:Acts) && ::ActiveRecord::Acts.const_defined?(:List)
        has_order_key = source.column_names.include?("position")
        @acts_as_list = installed && has_order_key && opt?(:acts_as_list)
      end

      def add_validations?
        !source.validations_for_root_table_added && opt?(:validate)
      end

      def opt?(option)
        !options.has_key?(option) || !options[option]
      end

    end

  end

  module ActionController

    def self.included(controller)
      controller.before_filter :find_object_by_id
      controller.helper_method :root_table
      controller.helper_method :table
      controller.helper_method :model
    end

    private

    def find_object_by_id
      @object = model.find(params[:id]) if params[:id]
    end

    def root_table
      @root_table ||= ::ActiveRecord::Base.all_root_tables[table.camelize].first
    end

    def table
      @table ||= params[:root_table_id]
    end

    def model
      @model ||= table.camelize.constantize
    end

    def flash_message(key)
      I18n.t(key, :table => model.human_name, :scope => [self.controller_name, :flash])
    end

    def render_per_table(action = nil)
      action ||= self.action_name
      begin
        render :action => "#{action}_#{table}"
      rescue ActionView::MissingTemplate
        render :action => action
      end
    end

    def update_sorting
      params[table].each_with_index do |id, index|
        model.update_all(["#{root_table.order}=?", index+1], ['id=?', id])
      end
    end

  end

  module FormBuilder

    def root_table_select(model, options = {})
      root_table = ::ActiveRecord::Base.all_root_tables[model.to_s.camelize].first
      collection_select(root_table.foreign_key, root_table.source.all, :id, root_table.field, options)
    end

  end

end
