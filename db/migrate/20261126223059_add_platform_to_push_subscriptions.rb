class AddPlatformToPushSubscriptions < ActiveRecord::Migration[8.1]
  def change
    # "web" (Web Push: endpoint + keys) or "ios" (the Snow Way iPhone app: endpoint holds the APNs device token)
    add_column :push_subscriptions, :platform, :string, default: "web", null: false
  end
end
