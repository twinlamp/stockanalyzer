class Stock < ActiveRecord::Base
	has_many :earnings, -> {order(:report)}
	serialize :prices, Array

	def get_trailing_eps
		earnings[3..-1].map {|e| [e.report.to_time.to_i*1000, e.ttm.round(2)] }
	end

	def set_prices
		temp = []
		(1..5).each do |i|
			temp += StockQuote::Stock.history(self.ticker, Date.today - i.years, Date.today - (i-1).years)
			break if StockQuote::Stock.history(self.ticker, Date.today - i.years, Date.today - (i-1).years).size < 250
		end
		self.prices = temp.sort_by {|quote| quote.date }.map {|quote| [ quote.date.to_time.to_i*1000, quote.close.round(2) ] }
	end

	def update_and_save_prices
		if self.prices.empty?
			self.set_prices
		elsif Time.at((self.prices[-1][0])/1000).to_date + 1 < Date.today
			StockQuote::Stock.history(self.ticker, Time.at((self.prices[-1][0])/1000).to_date + 1, Date.today).sort_by {|quote| quote.date }.map {|quote| [ quote.date.to_time.to_i*1000, quote.close.round(2) ] }.each do |q|
				self.prices << q
			end
		end
		self.save
	end

	def max_price
		prices.max_by {|q|q[1]}[1]
	end

	def max_eps
		get_trailing_eps.max_by { |q|q[1]}[1]
	end

	def min_price
		prices.min_by {|q|q[1]}[1]
	end

	def min_eps
		get_trailing_eps.min_by { |q|q[1]}[1]
	end

	def graph_max
		if earnings.length < 3 || max_price > max_eps*20
			return 1.2*max_price/20
		else
			return 1.2*max_eps
		end
	end

	def graph_min
		if earnings.length < 3 || min_price < min_eps*20
			return min_price/(1.2*20)
		else
			return min_eps/1.2
		end
	end

	def price
		prices.last[1]
	end

	def pe
		price/get_trailing_eps.last[1] if !earnings.empty?
	end

	def yoy
		100*((get_trailing_eps[-1][1]/get_trailing_eps[-5][1])-1) if !earnings.empty? && get_trailing_eps.length > 4
	end

	def peg
		pe/yoy if !yoy.nil?
	end
end
