require "spec_helper"
require 'rails_helper'
require 'user_methods'

feature 'update after create note' do
  scenario 'they visit stock page', js: true do
    FactoryGirl.create(:stock, :with_random_earnings, {ticker: 'AMBA'})
    visit stock_path(ticker: 'AMBA')
    expect {
      click_button 'Add new note'
      fill_in 'note_title', :with => 'test'
      fill_in_ckeditor 'note_body', :with => 'test'
      click_button 'Save note'
      wait_for_ajax
    }.to change{all('.panel-group > .panel-default').size}.by(1)
  end
end