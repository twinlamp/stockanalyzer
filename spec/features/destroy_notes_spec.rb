require "spec_helper"
require 'rails_helper'
require 'user_methods'

feature 'destroy_notes' do
  scenario 'they visit stock page', js: true do
    stock = FactoryGirl.create(:stock, :with_random_earnings, {ticker: 'AMBA'})
    stock.notes.create([attributes_for(:note),attributes_for(:note)])
    visit stock_path(ticker: 'AMBA')
    all('.panel-group > .panel-default').first.find(".btn-xs[data-method='delete']").click
    wait_for_ajax
    expect(all('.panel-group > .panel-default').size).to eq(1)
  end
end