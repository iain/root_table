module RootTablesHelper

  def link_to_manage_table(table_name, tables)
    link_to(tables.first.source.human_name, root_table_root_table_contents_path(table_name.to_s.underscore))
  end

  def used_by(tables)
    t(".used_by", :tables => tables.map{|t| target_description(t) }.uniq.to_sentence)
  end

  def target_description(table)
    used_as = table.options.has_key?(:to) ? t(".used_as", :to => table.target.human_attribute_name(table.to.to_s)) : nil
    "%s%s" % [ table.target.human_name, used_as]
  end

end
