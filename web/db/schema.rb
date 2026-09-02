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

ActiveRecord::Schema[8.0].define(version: 2026_09_02_192721) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gist"
  enable_extension "pg_catalog.plpgsql"

  create_table "availability_blocks", force: :cascade do |t|
    t.date "starts_on", null: false
    t.date "ends_on", null: false
    t.string "kind", default: "manual_closure", null: false
    t.string "source", default: "manual", null: false
    t.string "status", default: "confirmed", null: false
    t.string "summary"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.check_constraint "ends_on > starts_on", name: "availability_blocks_valid_date_range"
    t.check_constraint "kind::text = ANY (ARRAY['manual_closure'::character varying, 'direct_stay'::character varying]::text[])", name: "availability_blocks_valid_kind"
    t.check_constraint "source::text = ANY (ARRAY['direct'::character varying, 'manual'::character varying]::text[])", name: "availability_blocks_valid_source"
    t.check_constraint "status::text = ANY (ARRAY['tentative'::character varying, 'confirmed'::character varying, 'cancelled'::character varying]::text[])", name: "availability_blocks_valid_status"
    t.exclusion_constraint "daterange(starts_on, ends_on, '[)'::text) WITH &&", where: "(status)::text = ANY ((ARRAY['tentative'::character varying, 'confirmed'::character varying])::text[])", using: :gist, name: "availability_blocks_no_overlap"
  end

  create_table "booking_inquiries", force: :cascade do |t|
    t.date "check_in", null: false
    t.date "check_out", null: false
    t.integer "adults", default: 2, null: false
    t.integer "children", default: 0, null: false
    t.string "guest_name", null: false
    t.string "email", null: false
    t.string "phone"
    t.text "message"
    t.string "locale", default: "en", null: false
    t.string "status", default: "new", null: false
    t.datetime "consent_at"
    t.datetime "contacted_at"
    t.datetime "accepted_at"
    t.datetime "declined_at"
    t.bigint "availability_block_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "public_reference", null: false
    t.index ["availability_block_id"], name: "index_booking_inquiries_on_availability_block_id"
    t.index ["public_reference"], name: "index_booking_inquiries_on_public_reference", unique: true
    t.check_constraint "adults >= 1", name: "booking_inquiries_adults_positive"
    t.check_constraint "check_out > check_in", name: "booking_inquiries_valid_date_range"
    t.check_constraint "children >= 0", name: "booking_inquiries_children_not_negative"
    t.check_constraint "locale::text = ANY (ARRAY['en'::character varying, 'fr'::character varying]::text[])", name: "booking_inquiries_valid_locale"
    t.check_constraint "status::text = ANY (ARRAY['new'::character varying, 'contacted'::character varying, 'accepted'::character varying, 'declined'::character varying, 'cancelled'::character varying]::text[])", name: "booking_inquiries_valid_status"
  end

  create_table "calendar_events", force: :cascade do |t|
    t.bigint "calendar_import_id", null: false
    t.string "external_uid", null: false
    t.date "starts_on", null: false
    t.date "ends_on", null: false
    t.string "status", default: "confirmed", null: false
    t.string "fingerprint", null: false
    t.datetime "external_updated_at"
    t.string "summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_import_id", "external_uid"], name: "index_calendar_events_on_calendar_import_id_and_external_uid", unique: true
    t.index ["calendar_import_id"], name: "index_calendar_events_on_calendar_import_id"
    t.check_constraint "ends_on > starts_on", name: "calendar_events_valid_date_range"
    t.check_constraint "status::text = ANY (ARRAY['confirmed'::character varying, 'cancelled'::character varying]::text[])", name: "calendar_events_valid_status"
  end

  create_table "calendar_imports", force: :cascade do |t|
    t.string "provider", null: false
    t.boolean "active", default: true, null: false
    t.datetime "last_synced_at"
    t.datetime "last_error_at"
    t.text "last_error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_status", default: "never_synced", null: false
    t.integer "last_duration_ms"
    t.integer "last_event_count"
    t.index ["provider"], name: "index_calendar_imports_on_provider", unique: true
    t.check_constraint "last_duration_ms IS NULL OR last_duration_ms >= 0", name: "calendar_imports_last_duration_not_negative"
    t.check_constraint "last_event_count IS NULL OR last_event_count >= 0", name: "calendar_imports_last_event_count_not_negative"
    t.check_constraint "last_status::text = ANY (ARRAY['never_synced'::character varying, 'success'::character varying, 'failed'::character varying]::text[])", name: "calendar_imports_valid_last_status"
    t.check_constraint "provider::text = ANY (ARRAY['airbnb'::character varying, 'booking'::character varying]::text[])", name: "calendar_imports_valid_provider"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "stay_rules", force: :cascade do |t|
    t.integer "minimum_nights"
    t.integer "maximum_nights"
    t.integer "maximum_adults", default: 2, null: false
    t.integer "maximum_children", default: 1, null: false
    t.boolean "pets_allowed", default: true, null: false
    t.integer "allowed_check_in_days", array: true
    t.integer "allowed_check_out_days", array: true
    t.integer "booking_window_days"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.check_constraint "booking_window_days IS NULL OR booking_window_days >= 1", name: "stay_rules_booking_window_positive"
    t.check_constraint "maximum_adults >= 1", name: "stay_rules_maximum_adults_positive"
    t.check_constraint "maximum_children >= 0", name: "stay_rules_maximum_children_not_negative"
    t.check_constraint "maximum_nights IS NULL OR maximum_nights >= 1", name: "stay_rules_maximum_nights_positive"
    t.check_constraint "minimum_nights IS NULL OR minimum_nights >= 1", name: "stay_rules_minimum_nights_positive"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "booking_inquiries", "availability_blocks"
  add_foreign_key "calendar_events", "calendar_imports"
  add_foreign_key "sessions", "users"
end
