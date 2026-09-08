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
  # Cancelling an accepted booking releases its dates: the linked block is
  # cancelled first, then the inquiry. Payment-protected stays refuse to
  # change; every failure surfaces as a domain error instead of a raw Rails
  # exception leaking to the admin HTML or the agent API.
  def cancel(inquiry)
    raise Error, "only accepted bookings can be cancelled" unless inquiry.status_accepted?

    block = inquiry.availability_block
    raise Error, "payment in reconciliation: this stay cannot be cancelled" if block&.managed_by_payment?

    if block
      AvailabilityBlocks.cancel(block)
    else
      inquiry.update!(status: "cancelled")
    end
    inquiry
  rescue AvailabilityBlocks::Error, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => error
    raise Error, error.message.presence || "this booking cannot be cancelled"
  end
end
