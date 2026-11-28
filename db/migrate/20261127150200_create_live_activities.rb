class CreateLiveActivities < ActiveRecord::Migration[8.1]
  def change
    # iPhone storm tracker (Live Activity). The app gives us a token to start one by push,
    # and a token per running activity to update it.
    add_column :push_subscriptions, :live_start_token, :string

    create_table :live_activities do |t|
      t.string :endpoint, null: false # the device's APNs token, same as push_subscriptions.endpoint
      t.references :resort, null: false, foreign_key: true
      t.string :push_token
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.timestamps
    end
    add_index :live_activities, [ :endpoint, :resort_id, :ended_at ]
  end
end
