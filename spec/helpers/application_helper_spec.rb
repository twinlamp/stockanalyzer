require "rails_helper"

describe ApplicationHelper do
  describe "#graph_max" do
    it "choses 109 over 99" do
      ary = [{date: "2015-07-13".to_date, price: 99.000000, split: 1}, {date: "2015-06-19".to_date, price: 109.000000, split: 1}]
      stock = double('stock')
      allow(stock).to receive(:quotes).and_return(ary)
      allow(stock).to receive(:max_positive_ttm).and_return(0)
      expect(helper.graph_max(stock) * 20).to be_within(0.5).of(109 * 1.2)
    end
  end
end