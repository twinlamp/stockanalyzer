require "spec_helper"
require 'rails_helper'
require 'user_methods'

feature 'create_earnings' do
  scenario 'they visit stock page', js: true do
    FactoryGirl.create(:stock, :with_random_earnings, {ticker: 'AMBA'})
    visit stock_path(ticker: 'AMBA')
    expect {
      fill_in 'earning_report', :with => '2015-12-03'
      fill_in 'earning_q', :with => '3'
      fill_in 'earning_y', :with => '2016'
      fill_in 'earning_revenue', :with => '93.2'
      fill_in 'earning_eps', :with => '1.08'
      click_button 'Add earning'
      wait_for_ajax
    }.to change{all("[class^='earning-']").size}.by(1)
    expect {
      fill_in 'earning_report', :with => '2015-12-03'
      fill_in 'earning_q', :with => '3'
      fill_in 'earning_y', :with => '2016'
      fill_in 'earning_revenue', :with => '93.2'
      fill_in 'earning_eps', :with => '1.08'
      click_button 'Add earning'
      wait_for_ajax
    }.to change{all("[class^='earning-']").size}.by(1)
  end
end