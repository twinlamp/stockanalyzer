require 'rails_helper'

RSpec.describe Stock, :type => :model do
    it 'has a valid factory' do
        expect(build(:stock)).to be_valid
    end

    it { should validate_presence_of(:ticker) }    
    
    it { should validate_uniqueness_of(:ticker) }    

    it { should_not allow_value('AAAA').for(:ticker) }    

    it { should have_many(:earnings) }

    describe "Stock, .get_trailing_eps" do
      it 'does not return negative numbers' do
        l = FactoryGirl.create(:stock, :with_negative_1eps)
        expect(l.get_trailing_eps).to be_empty
      end

      it 'returns empty array if there is less than 3 earnings' do
        l = FactoryGirl.create(:stock, :with_3q_earnings)
        expect(l.get_trailing_eps).to be_empty
  	  end
    end

    describe "Stock, .graph_max" do
      it 'returns highest price/20 if there is not enough earning data' do
        l = FactoryGirl.create(:stock, :with_3q_earnings, :with_some_prices)
        expect(l.graph_max).to eq(1.2*59.51/20)
      end

      it 'choses highest value from earnings and prices' do
        l = FactoryGirl.create(:stock, :with_1eps, :with_some_prices)
        expect(l.graph_max).to eq(1.2*4)    
      end
    end

    describe "Stock, .graph_min" do
      it 'returns lowest price/20 if there is not enough earning data' do
        l = FactoryGirl.create(:stock, :with_3q_earnings, :with_some_prices)
        expect(l.graph_min).to eq(54.69/(1.2*20))
      end
      it 'choses lowest value from earnings and prices' do
        l = FactoryGirl.create(:stock, :with_1eps, :with_some_prices)
        expect(l.graph_min).to eq(54.69/(1.2*20))    
      end
    end

    describe "Stock, .pe" do
      it 'returns nil if earnings length < 4' do
        l = FactoryGirl.create(:stock, :with_some_prices, :with_3q_earnings)
        expect(l.pe).to be_nil
      end
      it 'returns nil if earnings ttm < 0' do
        l = FactoryGirl.create(:stock, :with_some_prices, :with_negative_1eps)
        expect(l.pe).to be_nil    
      end
      it 'returns nil if earnings ttm = 0' do
        l = FactoryGirl.create(:stock, :with_some_prices, :with_0eps)
        expect(l.pe).to be_nil    
      end
    end

    describe "Stock, .yoy_ttm" do
      it 'returns nil if earnings length < 8' do
        l = FactoryGirl.create(:stock, :with_some_prices, :with_3q_earnings)
        expect(l.yoy_ttm).to be_nil
      end
      it 'returns nil if last year ttm < 0' do
        l = FactoryGirl.create(:stock, :with_negative_1eps, :with_some_prices)
        expect(l.yoy_ttm).to be_nil    
      end
      it 'returns nil if last year ttm = 0' do
        l = FactoryGirl.create(:stock, :with_some_prices, :with_0eps)
        expect(l.yoy_ttm).to be_nil    
      end
=begin
      it 'returns 200% if result > 200%' do
        l = FactoryGirl.create(:stock, :with_some_prices, :with_0eps)
        expect(l.yoy_ttm).to be_nil    
      end
=end
    end

    describe "Stock, .peg" do
      it 'returns nil if yoy == 0' do
        l = FactoryGirl.create(:stock, :with_1eps, :with_some_prices)
        expect(l.peg).to be_nil
      end
      it 'returns nil if yoy == nil' do
        l = FactoryGirl.create(:stock, :with_0eps, :with_some_prices)
        expect(l.peg).to be_nil
      end
    end

    describe "Stock, .set_prices" do
      it 'does not throw an error for stock with recent IPO' do
        l = FactoryGirl.create(:stock, {ticker: 'GPRO'})
        expect{l.set_prices}.to_not raise_error
        expect(l.prices.length).to be > 250
      end
    end
    describe "Stock, .update_and_save_prices" do
      it 'updates prices and does not load duplicates' do
        l = FactoryGirl.create(:stock, {ticker: 'GPRO'})
        temp = StockQuote::Stock.history('GPRO', Date.today - 14.days, Date.today - 7.days)
        l.prices = temp.sort_by {|quote| quote.date }.map {|quote| [ quote.date.to_time.to_i*1000, quote.close.round(2) ] }
        expect{l.update_and_save_prices}.to change{ l.prices.length }.by_at_least(1)
        expect(l.prices.map{|q|q[0]}.uniq.length).to eq(l.prices.map{|q|[0]}.length)
      end
    end
    describe "Stock, .set_earnings" do
    	it 'does nothing if we have some earnings data already' do
        	l = FactoryGirl.create(:stock, :with_1eps, :with_some_prices)
        	expect{l.set_earnings}.to_not change{ l.earnings.length }
    	end
    	it 'adds 8 earning items if stock is present at estimize' do
        	l = FactoryGirl.create(:stock, :with_some_prices, {ticker: 'SWKS'})
        	expect{l.set_earnings}.to change{ l.earnings.length }.by(8)
    	end
    	it 'does nothing if stock is not present at estimize' do
        	l = FactoryGirl.create(:stock, :with_some_prices, {ticker: 'CRTO'})
        	expect{l.set_earnings}.to_not change{ l.earnings.length }
    	end
    end
end


=begin
    describe "Stock, .update_and_save_prices" do
      it 'adds last close price' do
        l = FactoryGirl.create(:stock)
        l.prices = [[(Date.today - 7.days).to_time.to_i*1000,10]]
        l.update_and_save_prices

        if Time.now > "19:01".to_time && Time.now < "24:00".to_time
        	expect(Time.at((l.prices[-1][0])/1000).to_date).to eq(Date.today)
        else
        	expect(Time.at((l.prices[-1][0])/1000).to_date).to eq(Date.today - 1)
        end     	
  	  end
    end
=end
