require 'rails_helper'

RSpec.describe StocksController, :type => :controller do

  describe "GET show" do
    context 'no prices data' do
      it 'redirects to special page' do
        get :show, {:ticker => 'YYYY'}
        expect(response).to redirect_to root_path
      end
    end

    context 'new record, no estimize data' do
      it 'returns @stock with some prices and empty earnings' do
        get :show, {:ticker => 'CRTO'}
        expect(assigns(:stock).prices).to_not be_empty
        expect(assigns(:stock).earnings).to be_empty
      end
    end

    context 'new record, estimize data' do
      it 'returns @stock with some prices and earnings' do
        get :show, {:ticker => 'SWKS'}
        expect(assigns(:stock).prices).to_not be_empty
        expect(assigns(:stock).earnings).to_not be_empty
      end
    end

    context 'existing record' do
      it 'returns @stock with some prices and earnings' do
        l = FactoryGirl.create(:stock, :with_some_prices, :with_1eps)
        allow(l).to receive(:update_and_save_prices).and_return( nil )
        get :show, {:ticker => l.ticker}
        expect(assigns(:stock).prices).to_not be_empty
        expect(assigns(:stock).earnings).to_not be_empty
      end
    end
  end

  describe "POST create" do
      it "sets session[:stock_id] to nil" do
        get :show, {:ticker => 'SWKS'}
        expect {
          xhr :post, :create
        }.to change{session[:stock_id]}.to(nil)
      end
  end
end
