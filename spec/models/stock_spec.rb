require 'rails_helper'
require 'byebug'
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

    describe "Stock, .get_earnings" do
        it 'returns array of up to 8 earning hashes if stock is present at estimize' do
            l = FactoryGirl.create(:stock, {ticker: 'SWKS'})
            expect(l.get_earnings.size).to eq(8)
        end
        it 'returns empty array if stock is not present at estimize' do
            l = FactoryGirl.create(:stock, {ticker: 'CRTO'})
            expect(l.get_earnings).to eq([])
        end
    end

    describe "Stock, .set_earnings" do
    	it 'creates earning item for each hash from .get_earnings' do
            ary = [{:q=>"1", :report=>"Thu, 16 Jan 2014", :y=>"2014", :revenue=>"505.0", :eps=>"0.67"},
                    {:q=>"2", :report=>"Tue, 22 Apr 2014", :y=>"2014", :revenue=>"481.0", :eps=>"0.62"},
                    {:q=>"3", :report=>"Thu, 17 Jul 2014", :y=>"2014", :revenue=>"587.0", :eps=>"0.83"},
                    {:q=>"4", :report=>"Thu, 06 Nov 2014", :y=>"2014", :revenue=>"718.2", :eps=>"1.12"},
                    {:q=>"1", :report=>"Thu, 22 Jan 2015", :y=>"2015", :revenue=>"805.5", :eps=>"1.26"},
                    {:q=>"2", :report=>"Thu, 30 Apr 2015", :y=>"2015", :revenue=>"762.1", :eps=>"1.15"},
                    {:q=>"3", :report=>"Thu, 23 Jul 2015", :y=>"2015", :revenue=>"810.0", :eps=>"1.34"},
                    {:q=>"4", :report=>"Thu, 05 Nov 2015", :y=>"2015", :revenue=>"880.8", :eps=>"1.52"}]
        	l = FactoryGirl.create(:stock, {ticker: 'SWKS'})
            allow(l).to receive(:get_earnings).and_return(ary)
        	expect{l.set_earnings}.to change{ l.earnings.length }.by(8)
    	end
    end

    describe "Stock, .update_earnings" do
        it 'creates new earning item for each hash from .get_earnings dated later then last earning item for this stock' do
            ary = [{:q=>"1", :report=>"Thu, 16 Jan 2014", :y=>"2014", :revenue=>"505.0", :eps=>"0.67"},
                    {:q=>"2", :report=>"Tue, 22 Apr 2014", :y=>"2014", :revenue=>"481.0", :eps=>"0.62"},
                    {:q=>"3", :report=>"Thu, 17 Jul 2014", :y=>"2014", :revenue=>"587.0", :eps=>"0.83"},
                    {:q=>"4", :report=>"Thu, 06 Nov 2014", :y=>"2014", :revenue=>"718.2", :eps=>"1.12"},
                    {:q=>"1", :report=>"Thu, 22 Jan 2015", :y=>"2015", :revenue=>"805.5", :eps=>"1.26"},
                    {:q=>"2", :report=>"Thu, 30 Apr 2015", :y=>"2015", :revenue=>"762.1", :eps=>"1.15"},
                    {:q=>"3", :report=>"Thu, 23 Jul 2015", :y=>"2015", :revenue=>"810.0", :eps=>"1.34"},
                    {:q=>"4", :report=>"Thu, 05 Nov 2015", :y=>"2015", :revenue=>"880.8", :eps=>"1.52"}]
            l = FactoryGirl.create(:stock, {ticker: 'SWKS'})
            l.earnings << FactoryGirl.create(:earning, q: 1, y: 2015, report:"Thu, 22 Jan 2015", eps: 1.26, revenue: 805.5)
            allow(l).to receive(:get_earnings).and_return(ary)
            expect{l.update_earnings}.to change{ l.earnings.length }.by(3)
        end
        it 'returns empty array if .get_earnings is empty' do
            ary = []
            l = FactoryGirl.create(:stock, {ticker: 'SWKS'})
            l.earnings << FactoryGirl.create(:earning, q: 1, y: 2015, report:"Thu, 22 Jan 2015", eps: 1.26, revenue: 805.5)
            allow(l).to receive(:get_earnings).and_return(ary)
            expect(l.update_earnings).to eq([])
        end
    end
end