class EarningsController < ApplicationController
  def create
    if @earning = Earning.create(earning_params)
      respond_to do |format|
        format.js { render :layout => false }
      end
    end
  end

  def destroy
    @earning = Earning.find(params[:id])
    @earning.destroy
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  private
    def earning_params
      params.require(:earning).permit(:report, :q, :y, :revenue, :eps, :stock_id)
    end
end