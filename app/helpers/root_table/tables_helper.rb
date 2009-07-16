module RootTable::TablesHelper

  def rt(key, options = {})
    t(key, options.merge(:scope => :root_table))
  end

  def link_to_manage_table(table_name, tables)
    link_to(tables.first.source.human_name, root_table_table_manage_index_path(table_name))
  end

  def used_by(tables)
    rt(:used_by, :tables => tables.map{|t| target_description(t) }.to_sentence)
  end

  def target_description(table)
    used_as = table.options.has_key?(:to) ? rt(:used_as, :to => table.target.human_attribute_name(table.to.to_s)) : nil
    "%s%s" % [ table.target.human_name, used_as]
  end

end
