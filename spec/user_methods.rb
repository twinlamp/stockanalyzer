require "spec_helper"
require 'rails_helper'

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end

  def fill_in_ckeditor(locator, opts)
    content = opts.fetch(:with).to_json
    page.execute_script <<-SCRIPT
  	CKEDITOR.instances['#{locator}'].setData(#{content});
  	$('textarea##{locator}').text(#{content});
    SCRIPT
  end