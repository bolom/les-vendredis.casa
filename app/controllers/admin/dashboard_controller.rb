module Admin
  class DashboardController < BaseController
    def show
      @new_inquiries_count = BookingInquiry.where(status: "new").count
      @payments_review_count = PaymentOrder.where(status: %w[settling review]).count
      @failed_notifications_count = BookingNotification.where(sent_at: nil).where("attempts > 0").count
      @draft_posts_count = JournalPost.where(published: false).count
      @recent_inquiries = BookingInquiry.order(created_at: :desc).limit(5)
      @pending_payment_orders = PaymentOrder.where(status: %w[settling review]).order(created_at: :desc).limit(5)
      @failed_notifications = BookingNotification.where(sent_at: nil).where("attempts > 0").order(updated_at: :desc).limit(5)
    end
  end
end
