require "httparty"
require "nokogiri"

module Estimize
  include HTTParty
  base_uri "https://www.estimize.com/"

  def self.get_earnings(ticker)
    page = self.get("https://www.estimize.com/" + ticker)
    parsed = Nokogiri::HTML(page.body)
    return [] if page.code == 404
    data = parsed.search("script").text.scan(/ReleaseCollection\((.*)\)/)[1][0][2..-3].gsub(/\"/,'').gsub(/},{/,'},,,{').split(',,,')
    hash_data = data.map do |earning|
      hash = {}
      earning[1..-2].gsub(/,(\D)/, '%%%\1').gsub(/(\D),/, '\1%%%').split('%%%').each do |el|
        key = el.split(':')[0]
        value = el.split(':')[1]
        hash[key] = value
      end
      hash
    end
    hash_data[0..-2].map do |earning|
      params = {}
      params[:q] = earning["name"][2]
      params[:report] = Time.at(earning["reportsAt"].to_i/1000).to_date
      params[:y] = earning["name"][-4..-1]
      params[:revenue] = earning["revenue"]
      params[:eps] = earning["eps"]
      Earning.new(params)
    end
  end
end