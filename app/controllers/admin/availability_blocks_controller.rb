module Admin
  # Anaïs only ever blocks dates: dates + optional label. The controller pins
  # kind/source/status (manual_closure / manual / confirmed) — no technical
  # status is ever exposed. Existing model guards are untouched: a manual
  # closure is the only kind this controller can create.
  class AvailabilityBlocksController < BaseController
    def index
      @availability_blocks = AvailabilityBlock.order(starts_on: :asc)
      @availability_blocks = @availability_blocks.where(status: params[:status]) if params[:status].in?(%w[confirmed tentative cancelled])
    end

    def new
      @availability_block = AvailabilityBlock.new(
        starts_on: params[:starts_on].presence || Date.current,
        ends_on: params[:ends_on].presence || Date.current + 1,
        summary: params[:summary].presence
      )
    end

    def create
      @availability_block = AvailabilityBlock.new(
        starts_on: availability_block_params[:starts_on],
        ends_on: availability_block_params[:ends_on],
        summary: availability_block_params[:summary],
        kind: "manual_closure",
        source: "manual",
        status: "confirmed"
      )

      if @availability_block.save
        redirect_to admin_calendar_path(month: @availability_block.starts_on.strftime("%Y-%m")),
                    notice: "Dates bloquées du #{l(@availability_block.starts_on, format: "%-d %B")} au #{l(@availability_block.ends_on, format: "%-d %B")}."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def cancel
      block = AvailabilityBlock.find(params[:id])
      if block.update(status: "cancelled")
        redirect_back fallback_location: admin_calendar_path, notice: "Blocage annulé : ces dates sont de nouveau disponibles."
      else
        redirect_back fallback_location: admin_calendar_path, alert: block.errors.full_messages.to_sentence
      end
    end

    private

    def availability_block_params
      params.require(:availability_block).permit(:starts_on, :ends_on, :summary)
    end
  end
end
