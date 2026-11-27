class AddDealsToPushSubscriptions < ActiveRecord::Migration[8.1]
  def change
    # Gear deal notifications are a separate opt-in (Apple guideline 4.5.4: promotional pushes need explicit consent).
    add_column :push_subscriptions, :deals, :boolean, default: false, null: false
  end
end
