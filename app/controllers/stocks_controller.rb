class StocksController < ApplicationController
	def show
		@prices = StockQuote::Stock.history(params[:ticker], Date.today - 2.years, Date.today).sort_by {|quote| quote.date }.map {|quote| [ quote.date.to_time.to_i*1000, quote.close.round(2) ] }
		@earnings = Stock.find_by(ticker: params[:ticker].upcase).get_trailing_eps if Stock.find_by(ticker: params[:ticker].upcase) && Stock.find_by(ticker: params[:ticker].upcase).earnings.length > 3
		@prices.max_by {|q|q[1]}[1] < (@earnings.max_by { |q|q[1]}[1])*20 ? @max = (@earnings.max_by { |q|q[1]}[1]*1.2).to_i : @max = ((@prices.max_by {|q|q[1]}[1])*1.2/20).to_i
		@prices.min_by {|q|q[1]}[1] < (@earnings.min_by { |q|q[1]}[1])*20 ? @min = ((@prices.min_by {|q|q[1]}[1])/(20*1.2)) : @min = ((@earnings.min_by { |q|q[1]}[1])/1.2)
	end
end