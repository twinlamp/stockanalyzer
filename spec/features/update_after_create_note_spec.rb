require "spec_helper"
require 'rails_helper'
require 'user_methods'

feature 'update after create note' do
  scenario 'they visit stock page', js: true do
    FactoryGirl.create(:stock, :with_random_earnings, {ticker: 'AMBA'})
    visit stock_path(ticker: 'AMBA')
    click_button 'Add new note'
    fill_in 'note_title', :with => 'test123'
    fill_in 'note_happened_at', :with => '2010-01-01'
    fill_in_ckeditor 'note_body', :with => 'test123'
    click_button 'Save note'
    wait_for_ajax
    expect(all('.panel-group > .panel-default').size).to eq(1)
    all('.panel-group > .panel-default').first.find(".btn-xs[data-toggle='modal']").click
    fill_in 'note_title', :with => 'test'
    fill_in_ckeditor 'note_body', :with => 'test'
    click_button 'Save note'
    wait_for_ajax
    expect(all('.panel-group > .panel-default').first.find("a[data-parent='#accordion']").text).to eq('test')
  end
end