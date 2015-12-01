class Earning < ActiveRecord::Base
  belongs_to :stock, inverse_of: :earnings
  validates :eps, presence: true
  validates :report, presence: true
  validate :report_is_valid_date
  validates :q, numericality: { less_than_or_equal_to: 4, greater_than_or_equal_to: 1, allow_blank: true }
  validates :y, numericality: { greater_than: 0, allow_blank: true }
  validates :revenue, numericality: { greater_than: 0, allow_blank: true }


  def ttm
  	i = stock.earnings.find_index(self)
  	stock.earnings[i-3..i].inject(0) {|sum, n|sum+n.eps} if i >= 3
  end

  def yoy
  	i = stock.earnings.find_index(self)
	100*((stock.earnings[i].eps/stock.earnings[i-4].eps)-1) if i >= 4 && stock.earnings[i-4].eps > 0
  end

  private
  def report_is_valid_date
    errors.add("Report date", "is invalid.") unless (report.try(:to_date) rescue nil)
  end
end
