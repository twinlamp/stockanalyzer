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

    describe "Stock, .update_earnings" do
        it 'adds to stock every earning item released after last one' do
            ary = [{:q=>"1", :report=>"Thu, 16 Jan 2014", :y=>"2014", :revenue=>"505.0", :eps=>"0.67"},
                    {:q=>"2", :report=>"Tue, 22 Apr 2014", :y=>"2014", :revenue=>"481.0", :eps=>"0.62"},
                    {:q=>"3", :report=>"Thu, 17 Jul 2014", :y=>"2014", :revenue=>"587.0", :eps=>"0.83"},
                    {:q=>"4", :report=>"Thu, 06 Nov 2014", :y=>"2014", :revenue=>"718.2", :eps=>"1.12"},
                    {:q=>"1", :report=>"Thu, 22 Jan 2015", :y=>"2015", :revenue=>"805.5", :eps=>"1.26"},
                    {:q=>"2", :report=>"Thu, 30 Apr 2015", :y=>"2015", :revenue=>"762.1", :eps=>"1.15"},
                    {:q=>"3", :report=>"Thu, 23 Jul 2015", :y=>"2015", :revenue=>"810.0", :eps=>"1.34"},
                    {:q=>"4", :report=>"Thu, 05 Nov 2015", :y=>"2015", :revenue=>"880.8", :eps=>"1.52"}].map {|e| Earning.new(e)}
            l = FactoryGirl.create(:stock, {ticker: 'SWKS'})
            l.earnings << FactoryGirl.create(:earning, q: 1, y: 2015, report:"Thu, 22 Jan 2015", eps: 1.26, revenue: 805.5)
            allow(Estimize).to receive(:get_earnings).and_return(ary)
            expect{l.update_earnings}.to change{ l.earnings.length }.by(3)
        end
        it 'adds to new stock every available earning item' do
            ary = [{:q=>"1", :report=>"Thu, 16 Jan 2014", :y=>"2014", :revenue=>"505.0", :eps=>"0.67"},
                    {:q=>"2", :report=>"Tue, 22 Apr 2014", :y=>"2014", :revenue=>"481.0", :eps=>"0.62"},
                    {:q=>"3", :report=>"Thu, 17 Jul 2014", :y=>"2014", :revenue=>"587.0", :eps=>"0.83"},
                    {:q=>"4", :report=>"Thu, 06 Nov 2014", :y=>"2014", :revenue=>"718.2", :eps=>"1.12"},
                    {:q=>"1", :report=>"Thu, 22 Jan 2015", :y=>"2015", :revenue=>"805.5", :eps=>"1.26"},
                    {:q=>"2", :report=>"Thu, 30 Apr 2015", :y=>"2015", :revenue=>"762.1", :eps=>"1.15"},
                    {:q=>"3", :report=>"Thu, 23 Jul 2015", :y=>"2015", :revenue=>"810.0", :eps=>"1.34"},
                    {:q=>"4", :report=>"Thu, 05 Nov 2015", :y=>"2015", :revenue=>"880.8", :eps=>"1.52"}].map {|e| Earning.new(e)}
            l = FactoryGirl.create(:stock, {ticker: 'SWKS'})
            allow(Estimize).to receive(:get_earnings).and_return(ary)
            expect{l.update_earnings}.to change{ l.earnings.length }.by(8)
        end
        it 'returns empty array if .get_earnings is empty' do
            ary = []
            l = FactoryGirl.create(:stock, {ticker: 'SWKS'})
            l.earnings << FactoryGirl.create(:earning, q: 1, y: 2015, report:"Thu, 22 Jan 2015", eps: 1.26, revenue: 805.5)
            allow(Estimize).to receive(:get_earnings).and_return(ary)
            expect{l.update_earnings}.to_not raise_error
        end
    end
end