# Preview all emails at http://localhost:3000/rails/mailers/booking_inquiry_mailer
#
# Sample inquiries are created inside a rolled-back transaction: nothing is
# persisted in the database, no BookingNotification is recorded, and no real
# email can be sent from here. Data is deterministic and independent from
# production records.
class BookingInquiryMailerPreview < ActionMailer::Preview
  def owner_notification
    preview(:owner_notification, status: "new")
  end

  def guest_acknowledgement
    preview(:guest_acknowledgement, status: "new", locale: "fr")
  end

  def guest_acceptance
    preview(:guest_acceptance, status: "accepted", locale: "en")
  end

  def guest_acceptance_fr
    preview(:guest_acceptance, status: "accepted", locale: "fr")
  end

  def guest_decline
    preview(:guest_decline, status: "declined")
  end

  def guest_cancellation
    preview(:guest_cancellation, status: "cancelled", locale: "fr")
  end

  private

  def preview(action, **attributes)
    result = nil
    BookingInquiry.transaction(requires_new: true) do
      inquiry = BookingInquiry.create!(sample_attributes.merge(attributes))
      result = BookingInquiryMailer.with(booking_inquiry: inquiry).public_send(action)
      result.message # render eagerly, while the inquiry still has an id
      raise ActiveRecord::Rollback
    end
    result
  end

  def sample_attributes
    {
      check_in: Date.new(2027, 2, 8),
      check_out: Date.new(2027, 2, 13),
      adults: 2,
      children: 1,
      guest_name: "Camille Dupont",
      email: "camille@example.com",
      locale: "en",
      public_reference: "LV-PR3V1EW1",
      status: "new"
    }
  end
end
