require "httparty"

module AlphaVantage
  include HTTParty
  base_uri "https://www.alphavantage.co/query?"

  def self.historical_quotes(ticker)
    params = "function=TIME_SERIES_DAILY_ADJUSTED&outputsize=full&symbol=#{ticker}&apikey=#{Rails.application.secrets.alphavantage_api_key}"
    json = self.get(base_uri + params).parsed_response
    return nil if json["Error Message"]
    quotes = json['Time Series (Daily)'].map do |k,v|
      {date: k.to_date, price: v['5. adjusted close'].to_f, split: v['8. split coefficient'].to_f }
    end
    quotes.sort_by { |q| q[:date] }
  end
end