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

    describe "Stock, .set_earnings" do
    	it 'adds 8 earning items if stock is present at estimize' do
        	l = FactoryGirl.create(:stock, {ticker: 'SWKS'})
        	expect{l.set_earnings}.to change{ l.earnings.length }.by(8)
    	end
    	it 'does nothing if stock is not present at estimize' do
        	l = FactoryGirl.create(:stock, {ticker: 'CRTO'})
        	expect{l.set_earnings}.to_not change{ l.earnings.length }
    	end
    end
end