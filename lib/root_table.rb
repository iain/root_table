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
    end

    class RootTable

      attr_reader :target_name, :options, :source

      def initialize(source, target_name, options)
        @source       = source
        @target_name  = target_name
        @options      = options

        add_order
        add_validations if add_validations?
        add_relations
      end

      def order
        return @order if @order
        if acts_as_list?
          @order = options[:order] || :position
        else
          @order = options[:order] || field
        end
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
        target.belongs_to(to, :class_name => source_name, :foreign_key => foreign_key)
        target.delegate(field, :to => to, :prefix => true, :allow_nil => true)
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


end
