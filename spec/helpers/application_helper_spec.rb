require "rails_helper"

describe ApplicationHelper do
  describe "#graph_max" do
    it "choses 109 over 99" do
      ary = [OpenStruct.new(trade_date: "2015-07-13", open: "102.93", high: "103.00", low: "99.559998", close: "100.489998", volume: "4039700", adjusted_close: "99.000000", symbol: "SWKS"), OpenStruct.new(trade_date: "2015-06-19", open: "110.769997", high: "112.879997", low: "109.43", close: "110.199997", volume: "4114300", adjusted_close: "109.000000", symbol: "SWKS") ]
      stock = double('stock')
      allow(stock).to receive(:quotes).and_return(ary)
      allow(stock).to receive(:max_ttm).and_return(0)
      expect(helper.graph_max(stock) * 20).to be_within(0.5).of(109 * 1.2)
    end
  end
end