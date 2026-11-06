class AddAlertStateToSubscribers < ActiveRecord::Migration[8.1]
  def change
    add_column :subscribers, :last_alerted_at, :datetime
    add_column :subscribers, :unsubscribed_at, :datetime
    add_column :subscribers, :welcomed_at, :datetime
  end
end
