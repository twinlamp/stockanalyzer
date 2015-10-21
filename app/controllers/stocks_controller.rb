class StocksController < ApplicationController
	before_action :set_stock

	def show
		if @stock.valid?
			@stock.new_record? ? @stock.set_prices : @stock.update_and_save_prices
			@stock.set_earnings
		else
			redirect_to root_path
		end
	end

private
	def set_stock
		@stock = Stock.find_by(ticker: params[:ticker].upcase) || Stock.new(ticker: params[:ticker].upcase)
	end 
end