# frozen_string_literal: true

# Shared accept/decline actions on BookingInquiry for the human admin and
# the agent API. All booking-safety rules stay inside the model (locking,
# availability re-check, exclusion constraint against double booking).
module BookingInquiries
  class Error < StandardError; end

  module_function

  def accept(inquiry)
    inquiry.accept!
    inquiry
  rescue ActiveRecord::RecordInvalid
    raise Error, "dates are no longer available"
  rescue ActiveRecord::StatementInvalid => error
    raise error unless error.cause.is_a?(PG::ExclusionViolation)

    raise Error, "dates are no longer available"
  end

  def decline(inquiry)
    inquiry.decline!
    inquiry
  rescue ActiveRecord::RecordInvalid
    raise Error, "this inquiry cannot be declined"
  end

  # Cancelling an accepted booking releases its dates: the linked block is
  # cancelled first, then the inquiry. Guards on the block model (managed
  # stay, unresolved payment) still apply and surface as domain errors.
  def cancel(inquiry)
    raise Error, "only accepted bookings can be cancelled" unless inquiry.status_accepted?

    if inquiry.availability_block
      AvailabilityBlocks.cancel(inquiry.availability_block)
    else
      inquiry.update!(status: "cancelled")
    end
    inquiry
  end
end
