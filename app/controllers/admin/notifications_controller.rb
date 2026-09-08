module Admin
  # Technical zone: booking notifications that failed delivery and are waiting
  # for the recurring sweeper or a manual look.
  class NotificationsController < BaseController
    before_action :require_technical_access

    def index
      @notifications = BookingNotification.where(sent_at: nil).where("attempts > 0").order(updated_at: :desc)
    end
  end
end
