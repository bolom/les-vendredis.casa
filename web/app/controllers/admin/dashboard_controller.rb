module Admin
  class DashboardController < ApplicationController
    def show
      @payment_reviews = PaymentOrder.where(status: %w[settling review paid]).order(created_at: :desc).limit(50)
      @notification_failures = BookingNotification.where(sent_at: nil).where("attempts > 0").order(updated_at: :desc).limit(50)
    end
  end
end
