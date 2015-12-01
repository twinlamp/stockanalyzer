class StocksController < ApplicationController
	before_action :set_stock, only: :show
	skip_before_action :destroy_unsaved_stock, only: :create

	def show
		if @stock.valid?
			@stock.update_and_save_prices
			@stock.set_earnings
			if @stock.new_record?
				@stock.save
				session[:stock_id] = @stock.id
			else
				@stock.save
			end
		else
			redirect_to root_path
		end
	end

	def create
		@stock = Stock.find(session[:stock_id])
		session[:stock_id] = nil
		respond_to do |format|
			format.js { render :layout => false }
		end
	end

	def destroy
		@stock = Stock.find(params[:id])
    @stock.destroy
		redirect_to root_path
	end

private
	def set_stock
		@stock = Stock.find_by(ticker: params[:ticker].upcase) || Stock.new(ticker: params[:ticker].upcase)
	end 
end