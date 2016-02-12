class EarningsController < ApplicationController

  def create
    @earning = Earning.new(earning_params)
    render layout: false if @earning.save
  end

  def destroy
    @earning = Earning.find(params[:id])
    render layout: false if @earning.destroy
  end

  private
    def earning_params
      params.require(:earning).permit(:report, :q, :y, :revenue, :eps, :stock_id)
    end
end