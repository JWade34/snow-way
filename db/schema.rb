# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_06_155703) do
  create_table "affiliate_clicks", force: :cascade do |t|
    t.string "page_path", null: false
    t.string "merchant", null: false
    t.string "label"
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_affiliate_clicks_on_created_at"
    t.index ["page_path", "created_at"], name: "index_affiliate_clicks_on_page_path_and_created_at"
  end

  create_table "gear_items", force: :cascade do |t|
    t.string "category", null: false
    t.string "brand"
    t.string "model", null: false
    t.string "season"
    t.string "size"
    t.string "status", default: "riding", null: false
    t.text "notes"
    t.text "public_note"
    t.boolean "public", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["public", "category"], name: "index_gear_items_on_public_and_category"
  end

  create_table "powder_reports", force: :cascade do |t|
    t.date "week_of"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["week_of"], name: "index_powder_reports_on_week_of", unique: true
  end

  create_table "resort_visits", force: :cascade do |t|
    t.integer "resort_id", null: false
    t.text "take"
    t.text "tips"
    t.string "when_ridden"
    t.integer "rating"
    t.boolean "published", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resort_id"], name: "index_resort_visits_on_resort_id", unique: true
  end

  create_table "resorts", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "nearest_airport_code"
    t.string "state_province"
    t.string "country"
    t.integer "elevation_base"
    t.integer "elevation_summit"
    t.string "website_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "monthly_snow_share"
    t.string "pass"
    t.string "pass_note"
    t.string "pass_source"
    t.json "other_passes"
    t.date "opening_date"
    t.string "opening_status"
    t.string "opening_source"
    t.date "facts_checked_on"
    t.integer "current_temp_f"
    t.integer "current_wind_mph"
    t.integer "current_weather_code"
    t.datetime "conditions_at"
  end

  create_table "search_stats", force: :cascade do |t|
    t.date "date", null: false
    t.string "source", null: false
    t.string "page", default: "", null: false
    t.string "query", default: "", null: false
    t.integer "clicks", default: 0, null: false
    t.integer "impressions", default: 0, null: false
    t.decimal "position", precision: 6, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date", "source", "page", "query"], name: "index_search_stats_unique", unique: true
    t.index ["source", "query", "date"], name: "index_search_stats_on_source_and_query_and_date"
  end

  create_table "snow_forecasts", force: :cascade do |t|
    t.integer "resort_id", null: false
    t.date "forecast_date"
    t.decimal "snowfall_inches"
    t.datetime "fetched_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "temp_high_f"
    t.integer "temp_low_f"
    t.decimal "snowfall_summit_inches"
    t.integer "weather_code"
    t.integer "wind_max_mph"
    t.index ["resort_id"], name: "index_snow_forecasts_on_resort_id"
  end

  create_table "subscribers", force: :cascade do |t|
    t.string "email", null: false
    t.integer "resort_id"
    t.integer "threshold_inches"
    t.string "token"
    t.datetime "confirmed_at"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_alerted_at"
    t.datetime "unsubscribed_at"
    t.datetime "welcomed_at"
    t.string "page_path"
    t.index ["email", "resort_id"], name: "index_subscribers_on_email_and_resort_id", unique: true
    t.index ["resort_id"], name: "index_subscribers_on_resort_id"
    t.index ["token"], name: "index_subscribers_on_token", unique: true
  end

  add_foreign_key "resort_visits", "resorts"
  add_foreign_key "snow_forecasts", "resorts"
  add_foreign_key "subscribers", "resorts"
end
