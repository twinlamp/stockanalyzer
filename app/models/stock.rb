class Stock < ActiveRecord::Base
  has_many :earnings,
           -> { order(:report) },
           inverse_of: :stock,
           dependent: :destroy
  has_many :notes
  attr_readonly :earnings_count
  validates :ticker, presence: true, uniqueness: true
  validate :price_data?

  def test
    byebug
    earnings.length
  end

  def update_earnings
    estimize_earnings = Estimize.get_earnings(ticker)
    new_earnings = estimize_earnings.select do |earning|
      earnings.empty? || earning.report > earnings.last.report
    end
    new_earnings.each { |earning| earnings << earning }
  end

  def price_data?
    errors.add(:ticker, 'no price data on yahoo finance') if quotes.nil?
  end

  def quotes
    ary = CSV.parse(File.open("./spec/support/quotes.csv", 'r')).map do |a|
      {date: a[0].to_date, price: a[1].to_f, split: a[2].to_f}
    end
    @quotes ||= ary.sort_by { |q| q[:date] }
  end

  def last_trade_price
    @last_trade_price ||= quotes.last.try(:[], :price)
  end

  def pe
    return nil unless earnings.last&.ttm&.to_f&.positive?
    @pe ||= last_trade_price / earnings.last.ttm
  end

  def yoy_ttm
    return nil unless earnings[-5]&.ttm&.to_f&.positive?
    @yoy_ttm ||= 100 * ((earnings[-1].ttm / earnings[-5].ttm) - 1)
  end

  def peg
    @peg ||= pe / yoy_ttm if pe && (yoy_ttm.to_f != 0)
  end

  def max_positive_ttm
    earnings.map { |e| e.ttm.to_f }.select(&:positive?).max
  end

  def min_positive_ttm
    earnings.map { |e| e.ttm.to_f }.select(&:positive?).min
  end

  def new_splits
    quotes.select { |q| q[:split] != 1 && q[:date] > last_split_date }
  end

  def mkt_cap
    yahoo.quotes([ticker], [:market_capitalization])[0][:market_capitalization]
  end

  def yahoo
    @yahoo ||= YahooFinance::Client.new
  end
end
