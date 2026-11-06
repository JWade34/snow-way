class CreatePowderReports < ActiveRecord::Migration[8.1]
  def change
    create_table :powder_reports do |t|
      t.date :week_of
      t.json :data

      t.timestamps
    end
    add_index :powder_reports, :week_of, unique: true
  end
end
