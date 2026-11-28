class CreateCrews < ActiveRecord::Migration[8.1]
  def change
    # A ski crew: friends who share a link and see where the powder is on everyone's passes. No accounts.
    create_table :crews do |t|
      t.string :token, null: false
      t.string :name, null: false
      t.timestamps
    end
    add_index :crews, :token, unique: true

    create_table :crew_members do |t|
      t.references :crew, null: false, foreign_key: true
      t.string :member_token, null: false # kept in a cookie on the member's device
      t.string :name
      t.string :pass
      t.timestamps
    end
    add_index :crew_members, [ :crew_id, :member_token ], unique: true

    add_reference :push_subscriptions, :crew, foreign_key: true
    add_column :push_subscriptions, :weekly, :boolean, default: false, null: false # Thursday Powder Report notification
  end
end
