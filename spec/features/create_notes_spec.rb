require "spec_helper"
require 'rails_helper'
require 'user_methods'

feature 'create_notes' do
  scenario 'they visit stock page', js: true do
    FactoryGirl.create(:stock, :with_random_earnings, {ticker: 'AMBA'})
    visit stock_path(ticker: 'AMBA')
    click_button 'Add new note'
    fill_in 'note_title', :with => 'test'
    fill_in 'note_happened_at', :with => '2010-01-01'
    fill_in_ckeditor 'note_body', :with => 'test'
    click_button 'Save note'
    wait_for_ajax
    expect(all("div[id^='myNoteModal']", visible: false).size).to eq(2)
    expect(all('.panel-group > .panel-default').size).to eq(1)
  end
end