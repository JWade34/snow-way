class CreateSeoOverrides < ActiveRecord::Migration[8.1]
  def change
    # Title/description replacements applied by the improvement loop. Deleting a row reverts the page.
    create_table :seo_overrides do |t|
      t.string :path, null: false
      t.string :title
      t.string :description
      t.timestamps
    end
    add_index :seo_overrides, :path, unique: true
  end
end
