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

ActiveRecord::Schema[8.1].define(version: 2026_09_16_202006) do
  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "categorizations", force: :cascade do |t|
    t.integer "category_id", null: false
    t.float "confidence"
    t.datetime "created_at", null: false
    t.string "detector_version"
    t.integer "term_id", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_categorizations_on_category_id"
    t.index ["term_id", "category_id", "confidence", "detector_version"], name: "idx_on_term_id_category_id_confidence_detector_vers_2ed1c1cbf9", unique: true
    t.index ["term_id"], name: "index_categorizations_on_term_id"
  end

  create_table "confirmations", force: :cascade do |t|
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.integer "term_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["category_id"], name: "index_confirmations_on_category_id"
    t.index ["term_id", "user_id"], name: "index_confirmations_on_term_id_and_user_id", unique: true
    t.index ["term_id"], name: "index_confirmations_on_term_id"
    t.index ["user_id", "term_id"], name: "index_confirmations_on_user_id_and_term_id", unique: true
    t.index ["user_id"], name: "index_confirmations_on_user_id"
  end

  create_table "detections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "detector_id", null: false
    t.string "detector_version"
    t.integer "term_id", null: false
    t.datetime "updated_at", null: false
    t.index ["detector_id", "term_id", "detector_version"], name: "idx_on_detector_id_term_id_detector_version_2afa383b1f", unique: true
    t.index ["detector_id"], name: "index_detections_on_detector_id"
    t.index ["term_id", "detector_id", "detector_version"], name: "idx_on_term_id_detector_id_detector_version_03898e846f", unique: true
    t.index ["term_id"], name: "index_detections_on_term_id"
  end

  create_table "detector_categories", force: :cascade do |t|
    t.integer "category_id", null: false
    t.float "confidence"
    t.datetime "created_at", null: false
    t.integer "detector_id", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "detector_id"], name: "index_detector_categories_on_category_id_and_detector_id"
    t.index ["category_id"], name: "index_detector_categories_on_category_id"
    t.index ["detector_id", "category_id"], name: "index_detector_categories_on_detector_id_and_category_id"
    t.index ["detector_id"], name: "index_detector_categories_on_detector_id"
  end

  create_table "detectors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_detectors_on_name", unique: true
  end

  create_table "fingerprints", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "value"
    t.index ["value"], name: "unique_fingerprint", unique: true
  end

  create_table "journals", force: :cascade do |t|
    t.json "additional_info"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_journals_on_name"
  end

  create_table "metrics_algorithms", force: :cascade do |t|
    t.integer "barcode"
    t.integer "citation"
    t.datetime "created_at", null: false
    t.integer "doi"
    t.integer "isbn"
    t.integer "issn"
    t.integer "journal_exact"
    t.integer "lcsh"
    t.date "month"
    t.integer "pmid"
    t.integer "suggested_resource_exact"
    t.integer "unmatched"
    t.datetime "updated_at", null: false
  end

  create_table "search_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "source"
    t.integer "term_id"
    t.datetime "updated_at", null: false
    t.index ["source"], name: "index_search_events_on_source"
    t.index ["term_id"], name: "index_search_events_on_term_id"
  end

  create_table "suggested_patterns", force: :cascade do |t|
    t.integer "category_id"
    t.float "confidence", default: 0.9
    t.datetime "created_at", null: false
    t.string "pattern", null: false
    t.string "shortcode", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["category_id"], name: "index_suggested_patterns_on_category_id"
    t.index ["pattern"], name: "index_suggested_patterns_on_pattern", unique: true
    t.index ["shortcode"], name: "index_suggested_patterns_on_shortcode", unique: true
  end

  create_table "suggested_resources", force: :cascade do |t|
    t.integer "category_id"
    t.float "confidence", default: 0.9
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["category_id"], name: "index_suggested_resources_on_category_id"
  end

  create_table "terms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "fingerprint_id"
    t.boolean "flag"
    t.boolean "label"
    t.string "phrase"
    t.integer "suggested_resource_id"
    t.datetime "updated_at", null: false
    t.index ["fingerprint_id"], name: "index_terms_on_fingerprint_id"
    t.index ["phrase"], name: "unique_phrase", unique: true
    t.index ["suggested_resource_id"], name: "index_terms_on_suggested_resource_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.boolean "suggestor", default: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
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
  add_foreign_key "suggested_patterns", "categories", on_delete: :nullify
  add_foreign_key "suggested_resources", "categories", on_delete: :nullify
  add_foreign_key "terms", "fingerprints"
  add_foreign_key "terms", "suggested_resources", on_delete: :nullify
end
