class AddSeoFieldsToResorts < ActiveRecord::Migration[8.1]
  def change
    add_column :resorts, :monthly_snow_share, :json
    add_column :resorts, :pass, :string
    add_column :resorts, :pass_note, :string
    add_column :resorts, :pass_source, :string
    add_column :resorts, :other_passes, :json
    add_column :resorts, :opening_date, :date
    add_column :resorts, :opening_status, :string
    add_column :resorts, :opening_source, :string
    add_column :resorts, :facts_checked_on, :date
  end
end
