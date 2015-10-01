class Earning < ActiveRecord::Base
  belongs_to :stock, dependent: :destroy

  def ttm
  	i = stock.earnings.find_index(self)
  	stock.earnings[i-3..i].inject(0) {|sum, n|sum+n.eps} if i >= 3
  end

  def yoy
  	i = stock.earnings.find_index(self)
	100*((stock.earnings[i].eps/stock.earnings[i-4].eps)-1) if i >= 4
  end
end
