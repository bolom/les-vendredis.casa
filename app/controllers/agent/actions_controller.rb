# frozen_string_literal: true

module Agent
  # Mutating capabilities for agents. Every action declares the permission
  # it needs, is audited (actor/action/date/target/result) and honors an
  # optional Idempotency-Key header. Sensitive operations (payments,
  # refunds, reconciliation) are intentionally absent: they stay behind
  # human validation in the admin HTML.
  class ActionsController < BaseController
    def block_dates
      run_agent_action!(permission: "block_dates", action: "block_dates") do
        block = AvailabilityBlocks.create(
          starts_on: required_date(:starts_on),
          ends_on: required_date(:ends_on),
          summary: params[:summary].presence
        )
        [ block, block_json(block) ]
      end
    end

    def cancel_block
      block = find_block
      run_agent_action!(permission: "cancel_block", action: "cancel_block", target: block) do
        AvailabilityBlocks.cancel(block)
        [ block, block_json(block.reload) ]
      end
    end

    def accept_booking
      inquiry = find_inquiry
      run_agent_action!(permission: "accept_booking", action: "accept_booking", target: inquiry) do
        BookingInquiries.accept(inquiry)
        [ inquiry, inquiry_json(inquiry.reload) ]
      end
    end

    def decline_booking
      inquiry = find_inquiry
      run_agent_action!(permission: "decline_booking", action: "decline_booking", target: inquiry) do
        BookingInquiries.decline(inquiry)
        [ inquiry, inquiry_json(inquiry.reload) ]
      end
    end

    def cancel_booking
      inquiry = find_inquiry
      run_agent_action!(permission: "cancel_booking", action: "cancel_booking", target: inquiry) do
        BookingInquiries.cancel(inquiry)
        [ inquiry, inquiry_json(inquiry.reload) ]
      end
    end

    def update_stay_rules
      run_agent_action!(permission: "update_stay_rules", action: "update_stay_rules") do
        rule = StayRules.update(stay_rule_params)
        [ rule, stay_rule_json(rule) ]
      end
    end

    def sync_calendars
      run_agent_action!(permission: "sync_calendars", action: "sync_calendars") do
        import = CalendarImports.enqueue_sync(required_provider)
        [ import, import_json(import) ]
      end
    end

    private

    def block_json(block)
      {
        id: block.id,
        kind: block.kind,
        status: block.status,
        starts_on: block.starts_on.iso8601,
        ends_on: block.ends_on.iso8601,
        summary: block.summary
      }
    end

    def inquiry_json(inquiry)
      {
        id: inquiry.id,
        reference: inquiry.public_reference,
        guest_name: inquiry.guest_name,
        status: inquiry.status,
        check_in: inquiry.check_in.iso8601,
        check_out: inquiry.check_out.iso8601,
        nights: inquiry.nights
      }
    end

    def stay_rule_json(rule)
      {
        nightly_price_eur: rule.nightly_price_eur&.to_s("F"),
        minimum_nights: rule.minimum_nights,
        maximum_nights: rule.maximum_nights,
        maximum_adults: rule.maximum_adults,
        maximum_children: rule.maximum_children,
        pets_allowed: rule.pets_allowed,
        booking_window_days: rule.booking_window_days,
        allowed_check_in_days: rule.allowed_check_in_days,
        allowed_check_out_days: rule.allowed_check_out_days
      }
    end

    def import_json(import)
      {
        provider: import.provider,
        last_status: import.last_status,
        last_synced_at: import.last_synced_at&.iso8601,
        stale: import.stale?
      }
    end

    def find_block
      AvailabilityBlock.find(params[:id])
    end

    def find_inquiry
      BookingInquiry.find(params[:id])
    end

    def required_date(name)
      value = params[name].presence or raise Agent::Errors::UnprocessableError, "#{name} is required"
      Date.iso8601(value)
    rescue ArgumentError, TypeError
      raise Agent::Errors::UnprocessableError, "#{name} must be an ISO date"
    end

    def required_provider
      provider = params[:provider].presence or raise Agent::Errors::UnprocessableError, "provider is required"
      raise Agent::Errors::UnprocessableError, "unknown provider" unless provider.in?(CalendarImport::PROVIDERS)

      provider
    end

    def stay_rule_params
      params.permit(
        :nightly_price_eur,
        :minimum_nights,
        :maximum_nights,
        :maximum_adults,
        :maximum_children,
        :pets_allowed,
        :booking_window_days,
        allowed_check_in_days: [],
        allowed_check_out_days: []
      ).to_h.symbolize_keys
    end
  end
end
