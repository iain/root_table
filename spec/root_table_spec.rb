require File.dirname(__FILE__) + '/spec_helper'

describe RootTable do

  context "default behaviour" do

    it "should add a belongs_to relation on the target model"
    it "should add a has_many relation on the source model"
    it "should delegate a name field to the root table"
    it "should validate presence of name"
    it "should validate uniqueness of name"
    it "should act as a list"

  end

  context "with a specified name" do

    it "should add a belongs_to relation on the target model"
    it "should add a has_many relation on the source model"
    it "should delegate the specified name field to the root table"
    it "should validate presence of name"
    it "should validate uniqueness of name"
    it "should act as a list"

  end

  context "without being a list" do

    it "should add a belongs_to relation on the target model"
    it "should add a has_many relation on the source model"
    it "should delegate a name field to the root table"
    it "should validate presence of name"
    it "should validate uniqueness of name"
    it "should not act as a list"

  end

  context "without validations" do

    it "should add a belongs_to relation on the target model"
    it "should add a has_many relation on the source model"
    it "should delegate a name field to the root table"
    it "should not validate presence of name"
    it "should not validate uniqueness of name"
    it "should act as a list"

  end

end
