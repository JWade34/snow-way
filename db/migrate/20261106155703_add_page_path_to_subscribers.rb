class AddPagePathToSubscribers < ActiveRecord::Migration[8.1]
  def change
    add_column :subscribers, :page_path, :string
  end
end
