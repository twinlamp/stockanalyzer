require 'rails_helper'

RSpec.describe EarningsController, :type => :controller do
  before :each do
    @stock = FactoryGirl.create(:stock)
    @earning = FactoryGirl.create(:earning, {stock_id: @stock.id})
  end

  describe "POST create" do
    it "creates a new Earning" do
      expect {
        xhr :post, :create, { earning: attributes_for(:earning).merge(stock_id: @stock.id) }
      }.to change(Earning, :count).by(1)
    end
  end

  describe "DELETE destroy" do
    it "removes an Earning" do
      expect {
        xhr :delete, :destroy, { id: @earning.id }
      }.to change(Earning, :count).by(-1)
    end
  end
end
