class AddAcceptedPriceSnapshotToBookingInquiries < ActiveRecord::Migration[8.0]
  def change
    add_column :booking_inquiries, :accepted_nightly_price_eur, :decimal, precision: 10, scale: 2
    add_column :booking_inquiries, :accepted_total_price_eur, :decimal, precision: 10, scale: 2
    add_column :booking_inquiries, :accepted_airbnb_nightly_price_eur, :decimal, precision: 10, scale: 2

    add_check_constraint :booking_inquiries,
      "accepted_nightly_price_eur IS NULL OR accepted_nightly_price_eur > 0",
      name: "booking_inquiries_positive_accepted_nightly_price"
    add_check_constraint :booking_inquiries,
      "accepted_total_price_eur IS NULL OR accepted_total_price_eur > 0",
      name: "booking_inquiries_positive_accepted_total_price"
    add_check_constraint :booking_inquiries,
      "accepted_airbnb_nightly_price_eur IS NULL OR accepted_airbnb_nightly_price_eur > 0",
      name: "booking_inquiries_positive_accepted_airbnb_price"
  end
end
