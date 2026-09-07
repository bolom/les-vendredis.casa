class CreateBookingNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :booking_notifications do |t|
      t.references :booking_inquiry, null: false, foreign_key: true
      t.string :event, null: false
      t.jsonb :payload, null: false
      t.datetime :sent_at
      t.datetime :first_attempt_at
      t.datetime :next_attempt_at
      t.integer :attempts, null: false, default: 0
      t.string :last_error
      t.string :provider_id
      t.timestamps
    end
    add_index :booking_notifications, [ :booking_inquiry_id, :event ], unique: true
  end
end
