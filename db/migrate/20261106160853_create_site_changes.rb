class CreateSiteChanges < ActiveRecord::Migration[8.1]
  def change
    # The change ledger: every SEO change, its baseline, and whether it was kept or reverted.
    create_table :site_changes do |t|
      t.string :path, null: false
      t.string :kind, null: false
      t.text :before_value
      t.text :after_value
      t.text :reason
      t.string :origin, null: false, default: "claude"
      t.string :status, null: false
      t.json :baseline
      t.json :result
      t.date :evaluate_on
      t.datetime :applied_at
      t.datetime :decided_at
      t.timestamps
    end
    add_index :site_changes, [ :path, :created_at ]
    add_index :site_changes, [ :status, :evaluate_on ]
  end
end
