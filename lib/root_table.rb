module RootTable

  module ActiveRecord

    attr_accessor :validations_for_root_table_added #:nodoc:

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

      # options and mutations
      field         = options[:field] || :name
      to            = options[:to] || self.name.underscore
      foreign_key   = options[:foreign_key] || "#{to}_id"
      target        = target_name.to_s.camelize.constantize
      target_plural = target_name.to_s.pluralize.to_sym

      # validations
      if self.add_validations_for_root_table?(options)
        self.validates_presence_of(field)
        self.validates_uniqueness_of(field)
        self.validations_for_root_table_added = true
      end

      # order and acts_as_list
      order = options[:order] || :position
      if self.acts_as_list?(options, order)
        self.acts_as_list :column => order
      else
        order = options[:order] || field
      end
      self.default_scope :order => order

      # relations
      self.has_many(target_plural, :foreign_key => foreign_key)
      target.belongs_to(to, :class_name => self.name, :foreign_key => foreign_key)
      target.delegate(field, :to => to, :prefix => true, :allow_nil => true)

      # debug
      # [ target_name, options, field, to, self, foreign_key, target, target_plural, order ].each { |v| puts v.inspect }

    end

    def acts_as_list?(options, order) #:nodoc:
      installed = ::ActiveRecord.const_defined?(:Acts) && ::ActiveRecord::Acts.const_defined?(:List)
      opted = !options.has_key?(:acts_as_list) || !options[:acts_as_list]
      has_order_key = self.column_names.include?(order.to_s)
      installed and opted and has_order_key
    end

    def add_validations_for_root_table?(options) #:nodoc:
      !self.validations_for_root_table_added && (!options.has_key?(:validate) || !options[:validate])
    end

  end

end
