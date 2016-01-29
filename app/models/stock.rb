class Stock < ActiveRecord::Base
	has_many :earnings, -> {order(:report)}, inverse_of: :stock, dependent: :destroy
	attr_readonly :earnings_count
	validates :ticker, presence: true, uniqueness: true
	validate :tickerness
	validate :price_data

	def update_earnings
		estimize_earnings = Estimize.get_earnings(ticker)
		estimize_earnings.select{|earning| earnings.empty? || earning.report > earnings.last.report }.each{|earning| earnings << earning }
	end

	def tickerness
		if yahoo.quote([ticker], [:stock_exchange]).stock_exchange == "N/A"
			errors.add(:ticker, "should be a proper ticker")
			return false
		else
			return true
		end
	end

	def quotes
		yahoo.historical_quotes(ticker, {start_date: Date.today - 5.years, end_date: Date.today, period: :daily})
	end

	def last_trade_price
		yahoo.quotes([ticker], [:last_trade_price])[0][:last_trade_price].to_f
	end

	def pe
		last_trade_price/earnings.last.ttm unless earnings.last.ttm.nil? || earnings.last.ttm < 0
	end

	def yoy_ttm
		100*((earnings[-1].ttm/earnings[-5].ttm)-1) unless earnings[-5].ttm.nil? || earnings[-5].ttm < 0
	end

	def peg
    	pe/yoy_ttm if pe && ( yoy_ttm.try :nonzero? )
	end

	def max_ttm
		return nil if earnings.length <= 3
		earnings[3..-1].max_by(&:ttm).ttm
	end

	def min_ttm
		return nil if earnings.length <= 3
		earnings[3..-1].min_by(&:ttm).ttm
	end

	def price_data
		if (quotes.any? rescue nil ).nil?
			errors.add(:ticker, "no price data on estimize")
			return false
		else
			return true
		end
	end

	def new_splits?
		(yahoo.splits(ticker).any? && ( !self.last_split_date || yahoo.splits(ticker).last.date > last_split_date ))
	end

	def mkt_cap
		yahoo.quotes([ticker], [:market_capitalization])[0][:market_capitalization]
	end

	def yahoo
		yahoo ||= YahooFinance::Client.new
	end
end
