module RootTable::ManageHelper

  def link_to_edit_root_table_item(table, id)
    link_to(rt(:edit), edit_root_table_table_manage_path(table, id))
  end

  def link_to_delete_root_table_item(table, id)
    link_to(rt(:delete), root_table_table_manage_path(table, id), :method => :delete, :confirm => rt(:confirm))
  end

end
