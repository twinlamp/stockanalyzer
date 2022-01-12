require 'rails_helper'

RSpec.describe StocksController, :type => :controller do
render_views
  describe "GET show" do
    context 'invalid ticker' do
      before(:each) do
        Stock.any_instance.stub(:quotes).and_return(nil)
      end 
      it 'redirects to root page and flashes an error' do
        get :show, {:ticker => 'YYYY'}
        expect(response).to redirect_to root_path
        expect(controller).to set_flash[:error].to(/Ticker is not valid or no price data available./)
      end
      it 'does not create new record' do
        get :show, {:ticker => 'YYYY'}
        expect(Stock.count).to eq(0)
      end
    end

    context 'no prices data' do
      before(:each) do 
        Stock.any_instance.stub(:quotes).and_return(nil)
      end
      it 'redirects to root page and flashes an error' do
        get :show, {:ticker => 'ACT'}
        expect(response).to redirect_to root_path
        expect(controller).to set_flash[:error].to(/Ticker is not valid or no price data available./)
      end
      it 'does not create new record' do
        get :show, {:ticker => 'ACT'}
        expect(Stock.count).to eq(0)
      end
    end

    context 'new record, no estimize data' do
      it 'returns @stock with empty earnings' do
        get :show, {:ticker => 'AMAVF'}
        expect(assigns(:stock).earnings).to be_empty
        expect(response).to render_template(:show)
      end
    end

    context 'new record, estimize data' do
      it 'returns @stock with earnings' do
        get :show, {:ticker => 'SWKS'}
        expect(assigns(:stock).earnings).to_not be_empty
        expect(response).to render_template(:show)
      end
      it 'does not flash earning message' do
        get :show, {:ticker => 'SWKS'}
        expect(flash.now[:info]).to be_nil
      end        
    end

    context 'existing record' do
      it 'returns @stock with and earnings' do
        l = FactoryGirl.create(:stock, :with_1eps)
        get :show, {:ticker => l.ticker}
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

    context 'existing record with splits' do
      it 'flashes an alert about split' do
        l = FactoryGirl.create(:stock, {:ticker => 'AAPL'})
        get :show, {:ticker => l.ticker}
        expect(response).to render_template(:show)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "POST create" do
    it "sets session[:stock_ticker] to nil" do
      get :show, {:ticker => 'SWKS'}
      xhr :post, :create
      expect(session[:stock_ticker]).to be_nil
    end
  end

  describe "DELETE destroy" do
    it "removes record" do
      l = FactoryGirl.create(:stock, {:ticker => 'AAPL'})
      get :show, {:ticker => l.ticker}
      xhr :delete, :destroy, id: l.id
      expect(Stock.count).to eq(0)
    end
    it "redirects to root" do
      l = FactoryGirl.create(:stock, {:ticker => 'AAPL'})
      get :show, {:ticker => l.ticker}
      xhr :delete, :destroy, id: l.id
      expect(response).to redirect_to root_path
    end
  end

  describe "PATCH update" do
    before :each do
      @stock = FactoryGirl.create(:stock, :with_1eps, {:ticker => 'AAPL'})
      request.env["HTTP_REFERER"] = "where_i_came_from"
    end
    context 'ignore split' do
      it 'redirects back' do
        xhr :patch, :update, id: @stock.id
        expect(response).to redirect_to "where_i_came_from"
      end
      it 'sets last split date to Date.today' do
        xhr :patch, :update, id: @stock.id
        @stock.reload
        expect(@stock.last_split_date).to eq(Date.today)
      end
      it 'does not change earnings' do
        xhr :patch, :update, id: @stock.id
        expect(@stock.earnings.first.eps).to eq(1)
      end
    end
    context 'update earnings' do
      it 'redirects back' do
        xhr :patch, :update, id: @stock.id, split: 2/1
        expect(response).to redirect_to "where_i_came_from"
      end
      it 'sets last split date to Date.today' do
        xhr :patch, :update, id: @stock.id, split: 2/1
        @stock.reload
        expect(@stock.last_split_date).to eq(Date.today)
      end
      it 'does not change earnings' do
        xhr :patch, :update, id: @stock.id, split: 2/1
        expect(@stock.earnings.first.eps).to eq(0.5)
      end
    end
  end  
end