class CreatePushSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :push_subscriptions do |t|
      t.string :endpoint, null: false
      t.string :p256dh, null: false
      t.string :auth, null: false
      t.references :resort, foreign_key: false
      t.integer :threshold_inches
      t.string :page_path
      t.boolean :standalone, default: false, null: false
      t.datetime :last_alerted_at
      t.integer :failures, default: 0, null: false
      t.timestamps
    end
    add_index :push_subscriptions, [ :endpoint, :resort_id ], unique: true
  end
end
