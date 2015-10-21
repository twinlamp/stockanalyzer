require 'rails_helper'

RSpec.describe Earning, :type => :model do
    it 'has a valid factory' do
        expect(build(:earning)).to be_valid
    end

    it { should validate_presence_of(:eps) }    
    
    it { should validate_presence_of(:report) }    
    
    it { should_not allow_value("2014/April/15000").for(:report) }   

    it { should validate_numericality_of(:q).is_less_than_or_equal_to(4) }   

    it { should validate_numericality_of(:y).is_greater_than(0) }

    it { should validate_numericality_of(:revenue).is_greater_than(0) }

    describe "Earning, .ttm" do
      it 'returns nil if there is no 3 previous earnings' do
        l = FactoryGirl.create(:stock, :with_3q_earnings)
        y = l.earnings.last
        expect(y.ttm).to be_nil
      end
    end

    describe "Earning, .yoy" do
      it 'returns nil if there isnt any earnings date from year before' do
        l = FactoryGirl.create(:stock, :with_some_prices, :with_3q_earnings)
        y = l.earnings.last
        expect(y.yoy).to be_nil
      end
      it 'returns nil if last year ttm < 0' do
        l = FactoryGirl.create(:stock, :with_negative_1eps, :with_some_prices)
        y = l.earnings.last
        expect(y.yoy).to be_nil    
      end
      it 'returns nil if last year ttm = 0' do
        l = FactoryGirl.create(:stock, :with_some_prices, :with_0eps)
        y = l.earnings.last
        expect(y.yoy).to be_nil    
      end
    end
end