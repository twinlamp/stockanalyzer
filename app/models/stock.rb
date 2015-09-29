class Stock < ActiveRecord::Base
	has_many :earnings

	def get_trailing_eps
		ary = self.earnings.sort_by {|e| e.report }
		ary[3..-1].each_with_index.map do |e,i|
			[e.report.to_time.to_i*1000, ary[i..i+3].inject(0){ |sum, n| sum + n.eps}.round(2)]
		end
	end
end
