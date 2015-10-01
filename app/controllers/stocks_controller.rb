class StocksController < ApplicationController
	before_action :set_stock

	def show
		@stock.new_record? ? @stock.set_prices : @stock.update_and_save_prices
	end

private
	def set_stock
		@stock = Stock.find_by(ticker: params[:ticker].upcase) || Stock.new(ticker: params[:ticker].upcase)
	end 
end