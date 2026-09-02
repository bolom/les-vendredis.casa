class AddPublicReferenceToBookingInquiries < ActiveRecord::Migration[8.0]
  def change
    add_column :booking_inquiries, :public_reference, :string, null: false
    add_index :booking_inquiries, :public_reference, unique: true
  end
end
