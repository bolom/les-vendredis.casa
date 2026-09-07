class CreatePaymentOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_orders do |t|
      t.string :public_id, null: false
      t.jsonb :quote, null: false
      t.jsonb :requirements, null: false
      t.datetime :expires_at, null: false
      t.string :status, null: false, default: "quoted"
      t.string :authorization_key
      t.jsonb :settlement
      t.references :booking_inquiry, foreign_key: true
      t.references :availability_block, foreign_key: true
      t.timestamps
    end
    add_index :payment_orders, :public_id, unique: true
    add_index :payment_orders, :authorization_key, unique: true
    add_check_constraint :payment_orders, "status IN ('quoted', 'settling', 'paid', 'review')", name: "payment_orders_valid_status"
  end
end
