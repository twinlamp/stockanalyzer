class Earning < ActiveRecord::Base
  belongs_to :stock, counter_cache: true
  validates :eps, presence: true
  validates :report, presence: true, uniqueness: { scope: :stock_id }
  validates :stock, presence: true
  validate :report_is_valid_date
  validates :q, uniqueness: { scope: %i[y stock_id] }, numericality: {
    less_than_or_equal_to: 4,
    greater_than_or_equal_to: 1,
    allow_blank: true
  }
  validates :y, numericality: { greater_than: 2000, allow_blank: true }

  def test
    byebug
    update_attribute(:stock_id, 6)
  end

  def ttm
    i = stock.earnings.find_index(self)
    return nil unless i >= 3
    stock.earnings[i - 3..i].inject(0) { |sum, n| sum + n.eps }
  end

  def yoy
    i = stock.earnings.find_index(self)
    return nil unless i >= 4 && stock.earnings[i - 4].eps.positive?
    100 * ((stock.earnings[i].eps / stock.earnings[i - 4].eps) - 1)
  end

  def to_highchart
    [report.to_time.to_i * 1000, ttm.round(2)]
  end

  private

  def report_is_valid_date
    errors.add('Report date', 'is invalid.') unless report&.to_date
  end
end
