class CreateResorts < ActiveRecord::Migration[8.0]
  def change
    create_table :resorts do |t|
      t.string :name
      t.string :slug
      t.decimal :latitude
      t.decimal :longitude
      t.string :nearest_airport_code
      t.string :state_province
      t.string :country
      t.integer :elevation_base
      t.integer :elevation_summit
      t.string :website_url

      t.timestamps
    end
  end
end
