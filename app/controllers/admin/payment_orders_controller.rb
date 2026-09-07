module Admin
  class PaymentOrdersController < ApplicationController
    def update
      raise ArgumentError unless params[:review_confirmed] == "1"
      PaymentOrder.find(params[:id]).reconcile!(outcome: params[:outcome], evidence: params[:evidence], actor: Current.user)
      redirect_to admin_root_path, notice: "Reconciliation recorded. No payment or refund was sent by this action."
    rescue ArgumentError, ActiveRecord::RecordInvalid
      redirect_to admin_root_path, alert: "Verify the outcome, transaction evidence and availability before recording reconciliation."
    end
  end
end
