class CreateSearchStats < ActiveRecord::Migration[8.1]
  def change
    # Daily search performance from Google Search Console and Bing Webmaster Tools.
    # query is "" for page-level totals; otherwise one row per (page, query).
    create_table :search_stats do |t|
      t.date :date, null: false
      t.string :source, null: false
      t.string :page, null: false, default: ""
      t.string :query, null: false, default: ""
      t.integer :clicks, null: false, default: 0
      t.integer :impressions, null: false, default: 0
      t.decimal :position, precision: 6, scale: 2
      t.timestamps
    end
    add_index :search_stats, [ :date, :source, :page, :query ], unique: true, name: "index_search_stats_unique"
    add_index :search_stats, [ :source, :query, :date ]
  end
end
