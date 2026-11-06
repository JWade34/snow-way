class CreateGearItems < ActiveRecord::Migration[8.1]
  def change
    create_table :gear_items do |t|
      t.string :category, null: false
      t.string :brand
      t.string :model, null: false
      t.string :season
      t.string :size
      t.string :status, null: false, default: "riding"
      t.text :notes
      t.text :public_note
      t.boolean :public, null: false, default: false
      t.timestamps
    end
    add_index :gear_items, [ :public, :category ]
  end
end
