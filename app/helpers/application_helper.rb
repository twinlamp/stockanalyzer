module ApplicationHelper

	def highchart_quotes(stock)
		stock.quotes.reverse.map {|quote| [ quote.trade_date.to_time.to_i*1000, quote.adjusted_close.to_f.round(2) ] }
	end

  def highchart_earnings(stock)
    stock.earnings[3..-1].select{|e|e.ttm > 0}.map{|e|e.to_highchart}
  end

  def graph_max(stock)
    if stock.max_ttm.to_i <= 0 || stock.quotes.max_by{|q|q.adjusted_close.to_f}.adjusted_close.to_f > stock.max_ttm*20
      (1.2*stock.quotes.max_by{|q|q.adjusted_close.to_f}.adjusted_close.to_f)/20
    else
      1.2*stock.max_ttm
    end
  end

  def graph_min(stock)
    if stock.min_ttm.to_i <= 0 || stock.quotes.min_by{|q|q.adjusted_close.to_f}.adjusted_close.to_f < stock.min_ttm*20
      stock.quotes.min_by{|q|q.adjusted_close.to_f}.adjusted_close.to_f/(1.2*20)
    else
      stock.min_ttm/1.2
    end
  end

  def q_y(earning)
    "#{earning.q}Q #{earning.y}" if earning.q
  end
end
