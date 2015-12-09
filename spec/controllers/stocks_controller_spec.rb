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
      it 'returns @stock with some @prices and empty earnings' do
        get :show, {:ticker => 'CRTO'}
        expect(assigns(:prices)).to_not be_empty
        expect(assigns(:stock).earnings).to be_empty
        expect(response).to render_template(:show)
      end
    end

    context 'new record, estimize data' do
      it 'returns @stock with some @prices and earnings' do
        get :show, {:ticker => 'SWKS'}
        expect(assigns(:prices)).to_not be_empty
        expect(assigns(:stock).earnings).to_not be_empty
        expect(response).to render_template(:show)
      end
    end

    context 'existing record' do
      it 'returns @stock with some @prices and earnings' do
        l = FactoryGirl.create(:stock, :with_1eps)
        get :show, {:ticker => l.ticker}
        expect(assigns(:prices)).to_not be_empty
        expect(assigns(:stock).earnings).to_not be_empty
        expect(response).to render_template(:show)
      end
    end

    context 'existing record without splits' do
      it 'renders show template' do
        l = FactoryGirl.create(:stock, :with_1eps, {:ticker => 'BRK-A'})
        get :show, {:ticker => l.ticker}
        expect(response).to render_template(:show)
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
