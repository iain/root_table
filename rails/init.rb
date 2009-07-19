ActionView::Helpers::FormBuilder.send(:include, RootTable::FormBuilder)
ActiveRecord::Base.extend RootTable::ActiveRecord
I18n.load_path.unshift(File.join(File.dirname(__FILE__), "..", "locale.yml"))
