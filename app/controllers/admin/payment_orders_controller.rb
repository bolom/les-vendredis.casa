module Admin
  class PaymentOrdersController < BaseController
    before_action :require_technical_access

    FILTERABLE_STATUSES = %w[pending quoted settling paid review refunded cancelled].freeze

    def index
      scope = PaymentOrder.order(created_at: :desc)
      if params[:status] == "pending"
        scope = scope.where(status: %w[settling review])
      elsif params[:status].in?(FILTERABLE_STATUSES)
        scope = scope.where(status: params[:status])
      end
      @payment_orders = scope
    end

    def show
      @payment_order = PaymentOrder.find(params[:id])
    end

    def update
      raise ArgumentError unless params[:review_confirmed] == "1"
      PaymentOrder.find(params[:id]).reconcile!(outcome: params[:outcome], evidence: params[:evidence], actor: Current.user)
      redirect_to admin_payment_order_path(params[:id]), notice: "Rapprochement enregistré. Cette action n’envoie aucun paiement ni remboursement."
    rescue ArgumentError, ActiveRecord::RecordInvalid
      redirect_to admin_payment_order_path(params[:id]), alert: "Vérifiez le résultat, la preuve de transaction et la disponibilité avant d’enregistrer le rapprochement."
    end
  end
end
