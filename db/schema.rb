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

ActiveRecord::Schema[8.0].define(version: 2026_01_06_192000) do
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
  end

  create_table "snow_forecasts", force: :cascade do |t|
    t.integer "resort_id", null: false
    t.date "forecast_date"
    t.decimal "snowfall_inches"
    t.datetime "fetched_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resort_id"], name: "index_snow_forecasts_on_resort_id"
  end

  add_foreign_key "snow_forecasts", "resorts"
end
