class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :get_stocks
  before_action :destroy_unsaved_stock
  helper_method :new_stock?

  def new_stock?
  	!(session[:stock_ticker].nil?)
  end

private
  def get_stocks
  	@stocks = Stock.order(:ticker)
  end

  def destroy_unsaved_stock
  	(Stock.find_by(ticker: session[:stock_ticker]).try(:destroy) rescue nil) if session[:stock_ticker]
  	session[:stock_ticker] = nil
  end
end
