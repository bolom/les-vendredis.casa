class CreateBookingAvailability < ActiveRecord::Migration[8.0]
  def change
    enable_extension "btree_gist"

    create_table :availability_blocks do |t|
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.string :kind, null: false, default: "manual_closure"
      t.string :source, null: false, default: "manual"
      t.string :status, null: false, default: "confirmed"
      t.string :summary
      t.text :note

      t.timestamps
    end

    add_check_constraint :availability_blocks, "ends_on > starts_on", name: "availability_blocks_valid_date_range"
    add_check_constraint :availability_blocks, "status IN ('tentative', 'confirmed', 'cancelled')", name: "availability_blocks_valid_status"
    add_check_constraint :availability_blocks, "kind IN ('manual_closure', 'direct_stay')", name: "availability_blocks_valid_kind"
    add_check_constraint :availability_blocks, "source IN ('direct', 'manual')", name: "availability_blocks_valid_source"
    add_exclusion_constraint :availability_blocks,
      "daterange(starts_on, ends_on, '[)') WITH &&",
      using: :gist,
      where: "status IN ('tentative', 'confirmed')",
      name: "availability_blocks_no_overlap"

    create_table :calendar_imports do |t|
      t.string :provider, null: false
      t.boolean :active, null: false, default: true
      t.datetime :last_synced_at
      t.datetime :last_error_at
      t.text :last_error_message

      t.timestamps
    end

    add_check_constraint :calendar_imports, "provider IN ('airbnb', 'booking')", name: "calendar_imports_valid_provider"
    add_index :calendar_imports, :provider, unique: true

    create_table :calendar_events do |t|
      t.references :calendar_import, null: false, foreign_key: true
      t.string :external_uid, null: false
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.string :status, null: false, default: "confirmed"
      t.string :fingerprint, null: false
      t.datetime :external_updated_at
      t.string :summary

      t.timestamps
    end

    add_check_constraint :calendar_events, "ends_on > starts_on", name: "calendar_events_valid_date_range"
    add_check_constraint :calendar_events, "status IN ('confirmed', 'cancelled')", name: "calendar_events_valid_status"
    add_index :calendar_events, [ :calendar_import_id, :external_uid ], unique: true

    create_table :booking_inquiries do |t|
      t.date :check_in, null: false
      t.date :check_out, null: false
      t.integer :adults, null: false, default: 2
      t.integer :children, null: false, default: 0
      t.string :guest_name, null: false
      t.string :email, null: false
      t.string :phone
      t.text :message
      t.string :locale, null: false, default: "en"
      t.string :status, null: false, default: "new"
      t.datetime :consent_at
      t.datetime :contacted_at
      t.datetime :accepted_at
      t.datetime :declined_at
      t.references :availability_block, foreign_key: true

      t.timestamps
    end

    add_check_constraint :booking_inquiries, "check_out > check_in", name: "booking_inquiries_valid_date_range"
    add_check_constraint :booking_inquiries, "adults >= 1", name: "booking_inquiries_adults_positive"
    add_check_constraint :booking_inquiries, "children >= 0", name: "booking_inquiries_children_not_negative"
    add_check_constraint :booking_inquiries, "locale IN ('en', 'fr')", name: "booking_inquiries_valid_locale"
    add_check_constraint :booking_inquiries,
      "status IN ('new', 'contacted', 'accepted', 'declined', 'cancelled')",
      name: "booking_inquiries_valid_status"

    create_table :stay_rules do |t|
      t.integer :minimum_nights
      t.integer :maximum_nights
      t.integer :maximum_adults, null: false, default: 2
      t.integer :maximum_children, null: false, default: 1
      t.boolean :pets_allowed, null: false, default: true
      t.integer :allowed_check_in_days, array: true
      t.integer :allowed_check_out_days, array: true
      t.integer :booking_window_days
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_check_constraint :stay_rules, "minimum_nights IS NULL OR minimum_nights >= 1", name: "stay_rules_minimum_nights_positive"
    add_check_constraint :stay_rules, "maximum_nights IS NULL OR maximum_nights >= 1", name: "stay_rules_maximum_nights_positive"
    add_check_constraint :stay_rules, "maximum_adults >= 1", name: "stay_rules_maximum_adults_positive"
    add_check_constraint :stay_rules, "maximum_children >= 0", name: "stay_rules_maximum_children_not_negative"
    add_check_constraint :stay_rules, "booking_window_days IS NULL OR booking_window_days >= 1", name: "stay_rules_booking_window_positive"
  end
end
