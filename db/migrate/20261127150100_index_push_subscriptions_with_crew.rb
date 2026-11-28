class IndexPushSubscriptionsWithCrew < ActiveRecord::Migration[8.1]
  def change
    remove_index :push_subscriptions, [ :endpoint, :resort_id ], unique: true
    add_index :push_subscriptions, [ :endpoint, :resort_id, :crew_id ], unique: true
  end
end
