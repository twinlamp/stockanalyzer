class Stock < ActiveRecord::Base
	has_many :earnings, -> {order(:report)}, inverse_of: :stock
	serialize :prices, Array
	validates :ticker, presence: true, uniqueness: true
	validate :tickerness

	def get_trailing_eps
		earnings[3..-1].map {|e| [e.report.to_time.to_i*1000, e.ttm.round(2)] }.select {|e| e[1] > 0 }
	end

	def set_earnings
		if self.earnings.empty?
			a = Mechanize.new
			begin
				page = a.get("https://www.estimize.com/" + ticker)
			rescue Mechanize::ResponseCodeError
				return
			end
			data = page.search("script").text.scan(/ReleaseCollection\((.*)\)/)[1][0][2..-3].gsub(/\"/,'').gsub(/},{/,'},,,{').split(',,,')
			hash_data = data.map do |earning|
				hash = {}
				earning[1..-2].gsub(/,(\D)/, '%%%\1').gsub(/(\D),/, '\1%%%').split('%%%').each do |el|
					key = el.split(':')[0]
					value = el.split(':')[1]
					hash[key] = value
				end
				hash
			end
			hash_data[0..-2].each do |earning|
				params = {}
				params[:q] = earning["name"][2]
				params[:report] = Time.at(earning["reportsAt"].to_i/1000).to_date
				params[:y] = earning["name"][-4..-1]
				params[:revenue] = earning["revenue"]
				params[:eps] = earning["eps"]
				self.earnings.build(params)
			end
		end
	end

	def set_prices
		temp = []
		(1..5).each do |i|
			temp += StockQuote::Stock.history(self.ticker, Date.today - i.years, Date.today - (i-1).years)
			break if StockQuote::Stock.history(self.ticker, Date.today - i.years, Date.today - (i-1).years).size < 250 # could bring an error if IPO was in first few days of january
		end
		self.prices = temp.sort_by {|quote| quote.date }.map {|quote| [ quote.date.to_time.to_i*1000, quote.close.round(2) ] }
	end

	def update_and_save_prices
		if self.prices.empty?
			self.set_prices
		elsif Time.at((self.prices[-1][0])/1000).to_date + 1 < Date.today && !(StockQuote::Stock.history(self.ticker, Time.at((self.prices[-1][0])/1000).to_date + 1, Date.today).try(:failure?) rescue false)
			StockQuote::Stock.history(self.ticker, Time.at((self.prices[-1][0])/1000).to_date + 1, Date.today).sort_by {|quote| quote.date }.map {|quote| [ quote.date.to_time.to_i*1000, quote.close.round(2) ] }.each do |q|
				self.prices << q
			end
		end
		self.save
	end

	def graph_max
		if earnings.length <= 3 || get_trailing_eps.empty? || prices.max_by {|q|q[1]}[1] > get_trailing_eps.max_by { |q|q[1]}[1]*20
			return (1.2*prices.max_by {|q|q[1]}[1])/20
		else
			return 1.2*get_trailing_eps.max_by { |q|q[1]}[1]
		end
	end

	def graph_min
		if earnings.length <= 3 || get_trailing_eps.empty? || prices.min_by {|q|q[1]}[1] < get_trailing_eps.min_by { |q|q[1]}[1]*20
			return (prices.min_by {|q|q[1]}[1])/(1.2*20)
		else
			return (get_trailing_eps.min_by { |q|q[1]}[1])/1.2
		end
	end

	def pe
		prices.last[1]/earnings.last.ttm if earnings.length >= 4 && earnings.last.ttm > 0
	end

	def yoy_ttm
		100*((earnings[-1].ttm/earnings[-5].ttm)-1) if earnings.length >= 8 && earnings[-5].ttm > 0
	end

	def peg
		pe/yoy_ttm if pe && ( yoy_ttm.try :nonzero? )
	end

	def tickerness
		if !(StockQuote::Stock.quote(ticker).try(:stock_exchange) rescue nil)
			errors.add(:ticker, "should be a proper ticker")
		end
	end
end
