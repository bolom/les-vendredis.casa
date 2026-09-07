class AddPaymentReconciliation < ActiveRecord::Migration[8.0]
  def change
    add_column :payment_orders, :reconciliation, :jsonb
    remove_check_constraint :payment_orders, name: "payment_orders_valid_status", expression: "status IN ('quoted', 'settling', 'paid', 'review')"
    add_check_constraint :payment_orders, "status IN ('quoted', 'settling', 'paid', 'review', 'refunded', 'cancelled')", name: "payment_orders_valid_status"
  end
end
