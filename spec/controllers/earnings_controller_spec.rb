require 'rails_helper'

RSpec.describe EarningsController, :type => :controller do

  describe "POST create" do
    it "creates a new Earning" do
      l = FactoryGirl.create(:stock)
      expect {
        xhr :post, :create, { earning: attributes_for(:earning).merge(stock_id: l.id) }
      }.to change(Earning, :count).by(1)
    end
  end

  describe "DELETE destroy" do
    it "removes an Earning" do
      l = FactoryGirl.create(:stock)
      e = FactoryGirl.create(:earning, {stock_id: l.id})
      expect {
        xhr :delete, :destroy, { id: l.id }
      }.to change(Earning, :count).by(-1)
    end
  end
end
