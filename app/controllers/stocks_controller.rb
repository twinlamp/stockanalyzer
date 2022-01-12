class StocksController < ApplicationController
  before_action :set_stock, only: :show
  skip_before_action :destroy_unsaved_stock, only: :create

  def show
    redirect_to root_path, flash: {error: "Ticker is not valid or no price data available."} and return false if !@stock.valid?
    # updates = @stock.update_earnings
    # messages = updates.map{|earning| "Earning info from #{earning.report} report added. Please remove it now if it is unnecessary."}
    # flash.now[:info] = messages.join("<br/>").html_safe if !new_stock? && messages.any?
    @stock.save if @stock.changed?
    if @stock.new_splits.any?
      @split = @stock.new_splits.last
      flash.now[:alert] = "There is an unaccounted stock split dated #{@split[:date]}. \
       Press 'Update earnings' button to automatically update earnings or press 'Ignore split' if everything is already fine."
    end
  end

  def create
    @stock = Stock.find_by(ticker: session[:stock_ticker])
    session[:stock_ticker] = nil
    render layout: false
  end

  def destroy
    @stock = Stock.find(params[:id])
    @stock.destroy
    redirect_to root_path
  end

  def update
    stock = Stock.find(params[:id])
    stock.earnings.each{ |e| e.update_attributes(eps: e.eps / params[:split].to_i) } if params[:split]
    stock.last_split_date = Date.today
    stock.save
    redirect_to(:back)
  end

  private
    def set_stock
      @stock = Stock.includes(:earnings).find_or_initialize_by(ticker: params[:ticker].upcase)
      if @stock.new_record?
        @stock.last_split_date = Date.today
        session[:stock_ticker] = @stock.ticker
      end
    end 
end