module RootTableContentsHelper

  def link_to_edit_root_table_item(table, id)
    link_to(t(".edit"), edit_root_table_root_table_content_path(table, id))
  end

  def link_to_delete_root_table_item(table, id)
    link_to(t(".delete"), root_table_root_table_content_path(table, id), :method => :delete, :confirm => t(".confirm"))
  end

end
