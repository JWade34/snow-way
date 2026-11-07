class CreateAiTracking < ActiveRecord::Migration[8.1]
  def change
    # Visits arriving from AI assistants (ChatGPT, Perplexity, Claude, Gemini, Copilot...), counted per day, source and page.
    create_table :ai_referrals do |t|
      t.date :visited_on, null: false
      t.string :source, null: false
      t.string :path, null: false
      t.integer :visits, null: false, default: 0
      t.timestamps
    end
    add_index :ai_referrals, %i[visited_on source path], unique: true

    # Weekly checks: does an AI answer engine cite snowway.app for a question we want to own?
    create_table :ai_citation_checks do |t|
      t.date :checked_on, null: false
      t.string :engine, null: false
      t.string :query, null: false
      t.boolean :cited, null: false, default: false
      t.boolean :mentioned, null: false, default: false
      t.json :snowway_urls, default: []
      t.json :sources, default: []
      t.text :answer_excerpt
      t.string :error
      t.timestamps
    end
    add_index :ai_citation_checks, %i[checked_on engine query], unique: true
  end
end
