class CreateAffiliateClicks < ActiveRecord::Migration[8.1]
  def change
    create_table :affiliate_clicks do |t|
      t.string :page_path, null: false
      t.string :merchant, null: false
      t.string :label
      t.datetime :created_at, null: false
    end
    add_index :affiliate_clicks, :created_at
    add_index :affiliate_clicks, [ :page_path, :created_at ]
  end
end
