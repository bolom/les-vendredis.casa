module Admin
  # Anaïs only ever blocks dates: dates + optional label. Kind/source/status
  # pinning and the guards live in AvailabilityBlocks (shared with the agent
  # API) — no technical status is ever exposed here. Existing model guards
  # are untouched: a manual closure is the only kind this controller creates.
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
      @availability_block = AvailabilityBlocks.create(
        starts_on: availability_block_params[:starts_on],
        ends_on: availability_block_params[:ends_on],
        summary: availability_block_params[:summary]
      )
      redirect_to admin_calendar_path(year: @availability_block.starts_on.year, month: @availability_block.starts_on.month),
                  notice: "Dates bloquées du #{l(@availability_block.starts_on, format: "%-d %B")} au #{l(@availability_block.ends_on, format: "%-d %B")}."
    rescue ActiveRecord::RecordInvalid, ArgumentError
      @availability_block ||= AvailabilityBlock.new(availability_block_params)
      render :new, status: :unprocessable_entity
    end

    def cancel
      block = AvailabilityBlock.find(params[:id])
      AvailabilityBlocks.cancel(block)
      redirect_back fallback_location: admin_calendar_path, notice: "Blocage annulé : ces dates sont de nouveau disponibles."
    rescue AvailabilityBlocks::Error => error
      redirect_back fallback_location: admin_calendar_path, alert: error.message
    end

    private

    def availability_block_params
      params.require(:availability_block).permit(:starts_on, :ends_on, :summary)
    end
  end
end
