module Admin
  class AvailabilityBlocksController < ApplicationController
    def index
      @availability_blocks = AvailabilityBlock.order(starts_on: :asc)
    end

    def new
      @availability_block = AvailabilityBlock.new(kind: "manual_closure", source: "manual", status: "confirmed")
    end

    def create
      @availability_block = AvailabilityBlock.new(availability_block_params.merge(kind: "manual_closure", source: "manual"))

      if @availability_block.save
        redirect_to admin_availability_blocks_path, notice: "Block created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @availability_block = AvailabilityBlock.find(params[:id])
    end

    def update
      @availability_block = AvailabilityBlock.find(params[:id])

      if @availability_block.update(availability_block_params)
        redirect_to admin_availability_blocks_path, notice: "Block updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def cancel
      AvailabilityBlock.find(params[:id]).update!(status: "cancelled")
      redirect_to admin_availability_blocks_path, notice: "Block cancelled."
    end

    private

    def availability_block_params
      params.require(:availability_block).permit(:starts_on, :ends_on, :status, :summary, :note)
    end
  end
end
