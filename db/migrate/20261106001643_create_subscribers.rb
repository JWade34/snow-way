class CreateSubscribers < ActiveRecord::Migration[8.1]
  def change
    create_table :subscribers do |t|
      t.string :email, null: false
      t.references :resort, null: true, foreign_key: true
      t.integer :threshold_inches
      t.string :token
      t.datetime :confirmed_at
      t.string :source

      t.timestamps
    end
    add_index :subscribers, :token, unique: true
    add_index :subscribers, [ :email, :resort_id ], unique: true
  end
end
