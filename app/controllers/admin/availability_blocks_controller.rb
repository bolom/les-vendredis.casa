module Admin
  class AvailabilityBlocksController < BaseController
    def index
      @availability_blocks = AvailabilityBlock.order(starts_on: :asc)
      @availability_blocks = @availability_blocks.where(status: params[:status]) if params[:status].in?(%w[confirmed tentative cancelled])
    end

    def new
      @availability_block = AvailabilityBlock.new(kind: "manual_closure", source: "manual", status: "confirmed")
    end

    def create
      @availability_block = AvailabilityBlock.new(availability_block_params.merge(kind: "manual_closure", source: "manual"))

      if @availability_block.save
        redirect_to admin_availability_blocks_path, notice: "Bloc de disponibilité créé."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @availability_block = AvailabilityBlock.find(params[:id])
    end

    def update
      @availability_block = AvailabilityBlock.find(params[:id])
      if managed_stay_form_update?
        @availability_block.errors.add(:base, "Le statut et les dates de ce séjour sont gérés par sa réservation : utilisez les actions de la demande")
        return render :edit, status: :unprocessable_entity
      end

      if @availability_block.update(availability_block_params)
        redirect_to admin_availability_blocks_path, notice: "Bloc de disponibilité mis à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def cancel
      block = AvailabilityBlock.find(params[:id])
      if block.update(status: "cancelled")
        redirect_to admin_availability_blocks_path, notice: "Bloc annulé. Les réservations acceptées liées sont annulées."
      else
        redirect_to admin_availability_blocks_path, alert: block.errors.full_messages.to_sentence
      end
    end

    private

    # A direct stay is owned by its booking: the generic form may not move its
    # status or dates. The cancel action stays available for blocks without an
    # unresolved payment (the model refuses those itself).
    def managed_stay_form_update?
      @availability_block.direct_stay? &&
        (availability_block_params[:status].present? || availability_block_params[:starts_on].present? || availability_block_params[:ends_on].present?)
    end

    def availability_block_params
      params.require(:availability_block).permit(:starts_on, :ends_on, :status, :summary, :note)
    end
  end
end
