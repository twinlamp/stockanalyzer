class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :get_stocks
  before_action :destroy_unsaved_stock
  helper_method :new_stock?
  include Estimize

  def new_stock?
  	!(session[:stock_ticker].nil?)
  end

private
  def get_stocks
  	@stocks = Stock.order(:ticker)
  end

  def calculate_chart
    quotes = yahoo.historical_quotes(@stock.ticker, {start_date: Date.today - 5.years, end_date: Date.today, period: :daily})
    @prices = quotes.sort_by {|quote| quote.trade_date }.map {|quote| [ quote.trade_date.to_time.to_i*1000, quote.adjusted_close.to_f.round(2) ] }
    @graph_max = (@stock.positive_trailing_eps.empty? || @prices.max_by {|q|q[1]}[1] > @stock.positive_trailing_eps.max_by {|q|q[1]}[1]*20) ? (1.2*@prices.max_by {|q|q[1]}[1])/20 : 1.2*@stock.positive_trailing_eps.max_by {|q|q[1]}[1]
    @graph_min = (@stock.positive_trailing_eps.empty? || @prices.min_by {|q|q[1]}[1] < @stock.positive_trailing_eps.min_by {|q|q[1]}[1]*20) ? (@prices.min_by {|q|q[1]}[1])/(1.2*20) :  @stock.positive_trailing_eps.min_by {|q|q[1]}[1]/1.2
    @pe = @prices.last[1]/@stock.earnings.last.ttm if @stock.earnings.size >= 4 && @stock.earnings.last.ttm > 0
    @yoy_ttm = 100*((@stock.earnings[-1].ttm/@stock.earnings[-5].ttm)-1) if @stock.earnings.size >= 8 && @stock.earnings[-5].ttm > 0
    @peg = @pe/@yoy_ttm if @pe && ( @yoy_ttm.try :nonzero? )
  end

  def yahoo
    yahoo ||= YahooFinance::Client.new
  end

  def destroy_unsaved_stock
  	(Stock.find_by(ticker: session[:stock_ticker]).try(:destroy) rescue nil) if session[:stock_ticker]
  	session[:stock_ticker] = nil
  end
end
