class CreateResortVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :resort_visits do |t|
      t.references :resort, null: false, foreign_key: true, index: { unique: true }
      t.text :take
      t.text :tips
      t.string :when_ridden
      t.integer :rating
      t.boolean :published, null: false, default: false
      t.timestamps
    end
  end
end
