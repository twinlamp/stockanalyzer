require "spec_helper"
require 'rails_helper'
require 'user_methods'

feature 'destroy_earnings' do
  scenario 'they visit stock page', js: true do
    FactoryGirl.create(:stock, :with_random_earnings, {ticker: 'AMBA'})
    visit stock_path(ticker: 'AMBA')
    all("[class^='earning-']").first.find(".btn-xs").click
    wait_for_ajax
    expect(all("[class^='earning-']").size).to eq(7)
  end
end