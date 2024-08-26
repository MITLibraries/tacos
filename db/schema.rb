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

ActiveRecord::Schema[7.1].define(version: 2024_08_23_195401) do
  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "detector_journals", force: :cascade do |t|
    t.string "name"
    t.json "additional_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_detector_journals_on_name"
  end

  create_table "detector_suggested_resources", force: :cascade do |t|
    t.string "title"
    t.string "url"
    t.string "phrase"
    t.string "fingerprint"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fingerprint"], name: "index_detector_suggested_resources_on_fingerprint", unique: true
    t.index ["phrase"], name: "index_detector_suggested_resources_on_phrase", unique: true
  end

  create_table "metrics_algorithms", force: :cascade do |t|
    t.date "month"
    t.integer "doi"
    t.integer "issn"
    t.integer "isbn"
    t.integer "pmid"
    t.integer "unmatched"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "journal_exact"
    t.integer "suggested_resource_exact"
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

  create_table "users", force: :cascade do |t|
    t.string "uid", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

end
