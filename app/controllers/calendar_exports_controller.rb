require "digest"

class CalendarExportsController < ApplicationController
  allow_unauthenticated_access only: :show

  def show
    return head :not_found unless valid_token?

    expires_now
    render plain: CalendarExports::Ical.new.call, content_type: "text/calendar; charset=utf-8"
  end

  private

  def valid_token?
    configured_token = AppConfig.fetch("ICAL_EXPORT_TOKEN", :calendars, :export_token)
    return false if configured_token.blank? || params[:token].blank?

    ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(params[:token]),
      Digest::SHA256.hexdigest(configured_token)
    )
  end
end
