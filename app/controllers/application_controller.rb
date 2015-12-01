class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :get_stocks
  before_action :destroy_unsaved_stock
  helper_method :new_stock?

  def new_stock?
  	!(session[:stock_id].nil?)
  end

private
  def get_stocks
  	@stocks = Stock.all.sort_by {|stock| stock.created_at}
  end

  def destroy_unsaved_stock
  	(Stock.try(:destroy, session[:stock_id]) rescue nil) if session[:stock_id]
  	session[:stock_id] = nil
  end
end
