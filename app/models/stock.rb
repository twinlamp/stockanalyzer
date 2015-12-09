class Stock < ActiveRecord::Base
	has_many :earnings, -> {order(:report)}, inverse_of: :stock, dependent: :destroy
	validates :ticker, presence: true, uniqueness: true
	validate :tickerness

	def get_trailing_eps
		earnings[3..-1].map {|e| [e.report.to_time.to_i*1000, e.ttm.round(2)] }.select {|e| e[1] > 0 }
	end

	def set_earnings
		get_earnings.each {|params| self.earnings.build(params)}
	end

	def update_earnings
		if !get_earnings.nil?
			get_earnings.select{|params| params[:report] > self.earnings.last.report }.each{|params|self.earnings.build(params)}
		else
			[]
		end
	end

	def get_earnings
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
		hash_data[0..-2].map do |earning|
			params = {}
			params[:q] = earning["name"][2]
			params[:report] = Time.at(earning["reportsAt"].to_i/1000).to_date
			params[:y] = earning["name"][-4..-1]
			params[:revenue] = earning["revenue"]
			params[:eps] = earning["eps"]
			params
		end
	end

	def tickerness
		if yahoo.quote([ticker], [:stock_exchange]).stock_exchange == "N/A"
			errors.add(:ticker, "should be a proper ticker")
		end
	end

	def yahoo
		yahoo ||= YahooFinance::Client.new
	end
end
