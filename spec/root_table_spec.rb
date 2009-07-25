require File.dirname(__FILE__) + '/spec_helper'

describe RootTable do

  before :each do
    silence_warnings do
      Foo = Class.new do
        extend RootTable::ActiveRecord
      end
      Bar = Class.new do
        extend RootTable::ActiveRecord
      end
    end
  end

  it "should add some order, relations and validations" do
    mock(Foo).default_scope(:order => :name)
    mock(Foo).has_many :bars, :foreign_key => "foo_id"
    mock(Foo).validates_presence_of :name
    mock(Foo).validates_uniqueness_of :name
    stub(Foo).column_names { [:name, :id] }
    Foo.root_table_for :bar
  end

  it "should add acts as list, when installed" do
    mock(Foo).acts_as_list(:column => :position)
    stub.instance_of(RootTable::ActiveRecord::RootTable).acts_as_list? { true }
    mock(Foo).default_scope(:order => :position)
    mock(Foo).has_many :bars, :foreign_key => "foo_id"
    mock(Foo).validates_presence_of :name
    mock(Foo).validates_uniqueness_of :name
    stub(Foo).column_names { [:name, :id] }
    Foo.root_table_for :bar
  end

  it "should be able to change the displayed field" do
    mock(Foo).acts_as_list(:column => :position)
    stub.instance_of(RootTable::ActiveRecord::RootTable).acts_as_list? { true }
    mock(Foo).default_scope(:order => :position)
    mock(Foo).has_many :bars, :foreign_key => "foo_id"
    mock(Foo).validates_presence_of :xxx
    mock(Foo).validates_uniqueness_of :xxx
    stub(Foo).column_names { [:name, :id] }
    Foo.root_table_for :bar, :field => :xxx
  end

  it "should be able to change the orderable field" do
    mock(Foo).acts_as_list(:column => :xxx)
    stub.instance_of(RootTable::ActiveRecord::RootTable).acts_as_list? { true }
    mock(Foo).default_scope(:order => :xxx)
    mock(Foo).has_many :bars, :foreign_key => "foo_id"
    mock(Foo).validates_presence_of :name
    mock(Foo).validates_uniqueness_of :name
    stub(Foo).column_names { [:name, :id] }
    Foo.root_table_for :bar, :order => :xxx
  end

  it "should be able to change the foreign key" do
    mock(Foo).default_scope(:order => :name)
    mock(Foo).has_many :bars, :foreign_key => "xxx_id"
    mock(Foo).validates_presence_of :name
    mock(Foo).validates_uniqueness_of :name
    stub(Foo).column_names { [:name, :id] }
    Foo.root_table_for :bar, :foreign_key => "xxx_id"
  end

  it "should be able to stop validations" do
    mock(Foo).default_scope(:order => :name)
    mock(Foo).has_many :bars, :foreign_key => "foo_id"
    dont_allow(Foo).validates_uniqueness_of :name
    dont_allow(Foo).validates_presence_of :name
    stub(Foo).column_names { [:name, :id] }
    Foo.root_table_for :bar, :validate => false
  end

  it "should add relations and delegate methods to the target" do
    mock(Foo).default_scope(:order => :name)
    mock(Foo).has_many :bars, :foreign_key => "foo_id"
    mock(Foo).validates_uniqueness_of :name
    mock(Foo).validates_presence_of :name
    stub(Foo).column_names { [:name, :id] }
    mock(Bar).belongs_to :foo, :class_name => "Foo", :foreign_key => "foo_id"
    mock(Bar).delegate :name, :to => "foo", :prefix => true, :allow_nil => true
    Foo.root_table_for :bar
    Bar.has_root_table :foo
  end

  it "should add relations and delegate methods to the target with a different relation name" do
    mock(Foo).default_scope(:order => :name)
    mock(Foo).has_many :bars, :foreign_key => "xxx_id"
    mock(Foo).validates_uniqueness_of :name
    mock(Foo).validates_presence_of :name
    stub(Foo).column_names { [:name, :id] }
    mock(Bar).belongs_to :xxx, :class_name => "Foo", :foreign_key => "xxx_id"
    mock(Bar).delegate :name, :to => "xxx", :prefix => true, :allow_nil => true
    Foo.root_table_for :bar, :to => "xxx"
    Bar.has_root_table :foo
  end

  it "should add relations and delegate methods to the target with a different field name" do
    mock(Foo).default_scope(:order => :xxx)
    mock(Foo).has_many :bars, :foreign_key => "foo_id"
    mock(Foo).validates_uniqueness_of :xxx
    mock(Foo).validates_presence_of :xxx
    stub(Foo).column_names { [] }
    mock(Bar).belongs_to :foo, :class_name => "Foo", :foreign_key => "foo_id"
    mock(Bar).delegate :xxx, :to => "foo", :prefix => true, :allow_nil => true
    Foo.root_table_for :bar, :field => :xxx
    Bar.has_root_table :foo
  end

end
