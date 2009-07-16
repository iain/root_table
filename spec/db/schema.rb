ActiveRecord::Schema.define(:version => 0) do
  create_table :products, :force => true do |t|
    t.column :name, :string
    t.column :description, :text
    t.column :category_id, :integer
  end
  create_table :categories, :force => true do |t|
    t.column :name, :string
    t.column :position, :integer
  end
end
