class Stock < ActiveRecord::Base
	has_many :earnings, -> {order(:report)}, inverse_of: :stock, dependent: :destroy
	attr_readonly :earnings_count
	validates :ticker, presence: true, uniqueness: true
	validate :tickerness
	validate :price_data

	def positive_trailing_eps
		return [] if self.earnings.length <= 3 
		self.earnings[3..-1].select{|e|e.ttm > 0}.map{|e|e.to_highchart}
	end

	def update_earnings
		estimize_earnings = Estimize.get_earnings(self.ticker)
		estimize_earnings.select{|earning| self.earnings.empty? || earning.report > self.earnings.last.report }.each{|earning| self.earnings << earning }
	end

	def tickerness
		if yahoo.quote([ticker], [:stock_exchange]).stock_exchange == "N/A"
			errors.add(:ticker, "should be a proper ticker")
			return false
		else
			return true
		end
	end

	def price_data
		if (yahoo.historical_quotes(ticker).any? rescue nil ).nil?
			errors.add(:ticker, "no price data on estimize")
			return false
		else
			return true
		end
	end

	def new_splits?
		(yahoo.splits(self.ticker).any? && ( !self.last_split_date || yahoo.splits(self.ticker).last.date > self.last_split_date ))
	end

	def mkt_cap
		yahoo.quotes([self.ticker], [:market_capitalization])[0][:market_capitalization]
	end

	def yahoo
		yahoo ||= YahooFinance::Client.new
	end
end
