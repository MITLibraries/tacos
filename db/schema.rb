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

ActiveRecord::Schema[7.1].define(version: 2024_10_29_181747) do
  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "categorizations", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "term_id", null: false
    t.float "confidence"
    t.string "detector_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "term_id", "detector_version"], name: "idx_on_category_id_term_id_detector_version_9f24c39900", unique: true
    t.index ["category_id"], name: "index_categorizations_on_category_id"
    t.index ["term_id", "category_id", "detector_version"], name: "idx_on_term_id_category_id_detector_version_4e10ba6204", unique: true
    t.index ["term_id"], name: "index_categorizations_on_term_id"
  end

  create_table "confirmations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "term_id", null: false
    t.integer "category_id"
    t.boolean "flag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_confirmations_on_category_id"
    t.index ["term_id", "user_id"], name: "index_confirmations_on_term_id_and_user_id", unique: true
    t.index ["term_id"], name: "index_confirmations_on_term_id"
    t.index ["user_id", "term_id"], name: "index_confirmations_on_user_id_and_term_id", unique: true
    t.index ["user_id"], name: "index_confirmations_on_user_id"
  end

  create_table "detections", force: :cascade do |t|
    t.integer "term_id", null: false
    t.integer "detector_id", null: false
    t.string "detector_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["detector_id", "term_id", "detector_version"], name: "idx_on_detector_id_term_id_detector_version_2afa383b1f", unique: true
    t.index ["detector_id"], name: "index_detections_on_detector_id"
    t.index ["term_id", "detector_id", "detector_version"], name: "idx_on_term_id_detector_id_detector_version_03898e846f", unique: true
    t.index ["term_id"], name: "index_detections_on_term_id"
  end

  create_table "detector_categories", force: :cascade do |t|
    t.integer "detector_id", null: false
    t.integer "category_id", null: false
    t.float "confidence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "detector_id"], name: "index_detector_categories_on_category_id_and_detector_id"
    t.index ["category_id"], name: "index_detector_categories_on_category_id"
    t.index ["detector_id", "category_id"], name: "index_detector_categories_on_detector_id_and_category_id"
    t.index ["detector_id"], name: "index_detector_categories_on_detector_id"
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

  create_table "detectors", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_detectors_on_name", unique: true
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
    t.integer "lcsh"
    t.integer "citation"
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

  add_foreign_key "categorizations", "categories"
  add_foreign_key "categorizations", "terms"
  add_foreign_key "confirmations", "categories"
  add_foreign_key "confirmations", "terms"
  add_foreign_key "confirmations", "users"
  add_foreign_key "detections", "detectors"
  add_foreign_key "detections", "terms"
  add_foreign_key "detector_categories", "categories"
  add_foreign_key "detector_categories", "detectors"
end
