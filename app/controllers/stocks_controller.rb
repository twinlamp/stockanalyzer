class StocksController < ApplicationController
  before_action :set_stock, only: :show
  before_action :check_tickerness, only: :show
  before_action :check_price_data, only: :show
  skip_before_action :destroy_unsaved_stock, only: :create

  def show
    updates = @stock.update_earnings
    updates.each do |earning|
      messages ||= []
      messages << "Earning info from #{earning.report} report added. Please remove it now if it is unnecessary."
    end
    flash.now[:info] = messages.join("<br/>").html_safe if (defined?(messages) && messages.any?)
    @stock.save if @stock.changed?
    if @stock.new_splits?
      @split = yahoo.splits(@stock.ticker).last 
      flash.now[:alert] = "There is an unaccounted #{@split.before}:#{@split.after} stock split dated #{@split.date}. Press 'Update earnings' button to automatically update earnings or press 'Ignore split' if everything is already fine."
    end
    calculate_chart
  end

  def create
    @stock = Stock.find_by(ticker: session[:stock_ticker])
    session[:stock_ticker] = nil
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  def destroy
    @stock = Stock.find(params[:id])
    @stock.destroy
    redirect_to root_path
  end

  def update
    stock = Stock.find(params[:id])
    stock.earnings.each{ |e| e.update_attributes(eps: (e.eps)/(params[:split].to_i)) } if params[:split]
    stock.last_split_date = Date.today
    stock.save
    redirect_to(:back)
  end

private
  def check_tickerness
    redirect_to root_path, flash: {error: "Ticker is not valid."} if !@stock.tickerness
  end

  def check_price_data
    redirect_to root_path, flash: {error: "No price data available."} if !@stock.price_data
  end

  def set_stock
    @stock = Stock.includes(:earnings).find_by(ticker: params[:ticker].upcase) || Stock.new(ticker: params[:ticker].upcase)
    if @stock.new_record?
      @stock.last_split_date = Date.today
      session[:stock_ticker] = @stock.ticker
    end
  end 
end