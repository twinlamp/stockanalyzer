module ApplicationHelper

  def highchart_quotes(stock)
    stock.quotes.map do |quote|
      [quote[:date].to_time.to_i * 1000, quote[:price].round(2)]
    end
  end

  def highchart_earnings(stock)
    return 'null' if stock.earnings.length < 4
    stock.earnings[3..-1].select { |e| e.ttm > 0 }.map(&:to_highchart)
  end

  def graph_max(stock)
    max_quote = stock.quotes.max_by { |q| q[:price] }[:price]
    max_ttm = stock.max_positive_ttm
    max_ttm && max_quote < max_ttm * 20 ? 1.2 * max_ttm : 1.2 * max_quote / 20
  end

  def graph_min(stock)
    min_quote = stock.quotes.min_by { |q| q[:price] }[:price]
    min_ttm = stock.min_positive_ttm
    min_ttm && min_quote > min_ttm * 20 ? min_ttm / 1.2 : min_quote / (1.2 * 20)
  end

  def q_y(earning)
    "#{earning.q}Q #{earning.y}" if earning.q
  end
end
