# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171109205256) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "earnings", force: :cascade do |t|
    t.integer "q"
    t.date "report"
    t.integer "y"
    t.float "revenue"
    t.float "eps"
    t.bigint "stock_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "extra"
    t.index ["stock_id"], name: "index_earnings_on_stock_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "stock_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "happened_at"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "ticker"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_split_date"
    t.integer "earnings_count"
  end

  add_foreign_key "earnings", "stocks"
end
