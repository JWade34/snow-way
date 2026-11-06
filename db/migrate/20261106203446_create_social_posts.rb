class CreateSocialPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :social_posts do |t|
      t.string :kind, null: false            # report | tip | brand | calendar
      t.string :tip_slug
      t.string :format, null: false, default: "post" # post | story
      t.text :caption
      t.datetime :scheduled_for, null: false
      t.string :status, null: false, default: "queued" # queued | published | failed | skipped
      t.json :result
      t.text :error
      t.datetime :published_at
      t.timestamps
    end
    add_index :social_posts, [ :status, :scheduled_for ]
    add_index :social_posts, [ :kind, :format, :scheduled_for ], unique: true
  end
end
