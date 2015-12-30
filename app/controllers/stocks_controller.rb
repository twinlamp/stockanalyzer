class StocksController < ApplicationController
	before_action :set_stock, only: :show
	skip_before_action :destroy_unsaved_stock, only: :create

	def show
		if @stock.tickerness
			if @stock.earnings.size == 0
				@stock.set_earnings
			else
				updates = @stock.update_earnings
				if updates.any?
					messages = []
					updates.each do |earning|
						messages << "Earning info from #{earning[:report]} report added. Please remove it now if it is unnecessary."
					end
					flash.now[:info] = messages.join("<br/>").html_safe
				end
			end
			if @stock.new_record?
				@stock.last_split_date = Date.today
				@stock.save
				session[:stock_id] = @stock.id
			else
				@stock.save if @stock.changed?
			end
			if (yahoo.splits(@stock.ticker).any? && ( !@stock.last_split_date || yahoo.splits(@stock.ticker).last.date > @stock.last_split_date ))
				@split = yahoo.splits(@stock.ticker).last
				flash.now[:alert] = "There is an unaccounted #{@split.before}:#{@split.after} stock split dated #{@split.date}. Press 'Update earnings' button to automatically update earnings or press 'Ignore split' if everything is already fine."
			end
			calculate_chart
		else
			redirect_to root_path, flash: {error: "Ticker is not valid."}
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

	def update
		stock = Stock.find(params[:id])
		stock.earnings.each{ |e| e.update_attributes(eps: (e.eps)/(params[:split].to_i)) } if params[:split]
		stock.last_split_date = Date.today
		stock.save
		redirect_to(:back)
	end

private
	def set_stock
		@stock = Stock.includes(:earnings).find_by(ticker: params[:ticker].upcase) || Stock.new(ticker: params[:ticker].upcase)
	end 
end