class Stock < ActiveRecord::Base
  has_many :earnings, -> {order(:report)}, inverse_of: :stock, dependent: :destroy
  has_many :notes
  attr_readonly :earnings_count
  validates :ticker, presence: true, uniqueness: true
  validate :has_price_data

  def update_earnings
    estimize_earnings = Estimize.get_earnings(ticker)
    new_earnings = estimize_earnings.select do |earning|
      earnings.empty? || earning.report > earnings.last.report
    end
    new_earnings.each { |earning| earnings << earning }
  end

  def has_price_data
    errors.add(:ticker, "no price data on yahoo finance") if (quotes.any? rescue nil).nil?
  end

  def quotes
    @quotes ||= AlphaVantage.historical_quotes(ticker)
  end

  def last_trade_price
    @last_trade_price ||= quotes.last.try(:[], :price)
  end

  def pe
    @pe ||= last_trade_price/earnings.last.ttm if earnings.last.try(:ttm).to_f > 0
  end

  def yoy_ttm
    @yoy_ttm ||= 100*((earnings[-1].ttm / earnings[-5].ttm) - 1) if earnings[-5].try(:ttm).to_f > 0
  end

  def peg
    @peg ||= pe / yoy_ttm if pe && (yoy_ttm.to_f != 0)
  end

  def max_positive_ttm
    earnings.map { |e| e.ttm.to_f }.select { |ttm| ttm > 0 }.max
  end

  def min_positive_ttm
    earnings.map { |e| e.ttm.to_f }.select { |ttm| ttm > 0 }.min
  end

  def new_splits
    quotes.select { |q| q[:split] != 1 && q[:date] > last_split_date }
  end

  def mkt_cap
    yahoo.quotes([ticker], [:market_capitalization])[0][:market_capitalization]
  end

  def yahoo
    yahoo ||= YahooFinance::Client.new
  end
end
