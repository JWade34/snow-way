class AddWeeklyReportToSubscribers < ActiveRecord::Migration[8.1]
  def change
    # Only people who signed up after the consent text named the weekly report (2026-11-08), or who opt in, get it.
    add_column :subscribers, :weekly_report, :boolean, default: false, null: false
    add_column :subscribers, :weekly_sent_at, :datetime
  end
end
