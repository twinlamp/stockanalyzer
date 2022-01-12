require 'rails_helper'

RSpec.describe EarningsController, :type => :controller do
  before :each do
    @stock = FactoryGirl.create(:stock)
    @earning = FactoryGirl.create(:earning, {stock_id: @stock.id})
  end

  describe "POST create" do
    it "creates a new Earning" do
      xhr :post, :create, { earning: attributes_for(:earning).merge(stock_id: @stock.id) }
      expect(Earning.count).to eq(2)
    end
  end

  describe "DELETE destroy" do
    it "removes an Earning" do
      xhr :delete, :destroy, { id: @earning.id }
      expect(Earning.count).to eq(0)
    end
  end
end
