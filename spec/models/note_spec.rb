require 'rails_helper'
require 'byebug'
RSpec.describe Note, :type => :model do
  it 'has a valid factory' do
      expect(build(:note)).to be_valid
  end

  it { should validate_presence_of(:title) }    

  it { should validate_presence_of(:body) }    

  it { should belong_to(:stock) }    

end