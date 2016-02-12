require "spec_helper"
require 'rails_helper'
require 'user_methods'

feature 'destroy_notes' do
  scenario 'they visit stock page', js: true do
    stock = FactoryGirl.create(:stock, :with_random_earnings, {ticker: 'AMBA'})
    stock.notes.create([attributes_for(:note),attributes_for(:note)])

    visit stock_path(ticker: 'AMBA')
    expect {
      all('.panel-group > .panel-default').first.find(".btn-xs[data-toggle='modal']").click
      fill_in 'note_title', :with => 'test'
      fill_in_ckeditor 'note_body', :with => 'test'
      click_button 'Save note'
      wait_for_ajax
    }.to change{all('.panel-group > .panel-default').first.find("a[data-parent='#accordion']").text}.to('test')
  end
end