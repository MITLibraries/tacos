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

ActiveRecord::Schema[7.1].define(version: 2024_06_21_132150) do
  create_table "aggregate_matches", force: :cascade do |t|
    t.integer "doi"
    t.integer "issn"
    t.integer "isbn"
    t.integer "pmid"
    t.integer "unmatched"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "monthly_matches", force: :cascade do |t|
    t.date "month"
    t.integer "doi"
    t.integer "issn"
    t.integer "isbn"
    t.integer "pmid"
    t.integer "unmatched"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "search_events", force: :cascade do |t|
    t.integer "term_id"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source"], name: "index_search_events_on_source"
    t.index ["term_id"], name: "index_search_events_on_term_id"
  end

  create_table "terms", force: :cascade do |t|
    t.string "phrase"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phrase"], name: "unique_phrase", unique: true
  end

end
