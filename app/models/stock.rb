class Stock < ActiveRecord::Base
  has_many :earnings, -> {order(:report)}, inverse_of: :stock, dependent: :destroy
  attr_readonly :earnings_count
  validates :ticker, presence: true, uniqueness: true
  validate :has_price_data

  def update_earnings
    estimize_earnings = Estimize.get_earnings(ticker)
    estimize_earnings.select{|earning| earnings.empty? || earning.report > earnings.last.report }.each{|earning| earnings << earning }
  end

  def has_price_data
    errors.add(:ticker, "no price data on yahoo finance") if (quotes.any? rescue nil ).nil?
  end

  def quotes
    @quotes ||= yahoo.historical_quotes(ticker, {start_date: Date.today - 5.years, end_date: Date.today, period: :daily})
  end

  def last_trade_price
    @last_trade_price ||= quotes.first.adjusted_close.to_f
  end

  def pe
    @pe ||= last_trade_price/earnings.last.ttm unless earnings.last.ttm.to_i <= 0
  end

  def yoy_ttm
    @yoy_ttm ||= 100*((earnings[-1].ttm/earnings[-5].ttm)-1) unless earnings[-5].ttm.to_i <= 0
  end

  def peg
    @peg ||= pe/yoy_ttm if pe && (yoy_ttm.to_i != 0)
  end

  def max_ttm
    return nil if earnings.length <= 3
    earnings[3..-1].max_by(&:ttm).ttm
   end

  def min_ttm
    return nil if earnings.length <= 3
    earnings[3..-1].min_by(&:ttm).ttm
  end

  def new_splits
    yahoo.splits(ticker).select{|s|s.date > last_split_date}
  end

  def mkt_cap
    yahoo.quotes([ticker], [:market_capitalization])[0][:market_capitalization]
  end

  def yahoo
    yahoo ||= YahooFinance::Client.new
  end
end
