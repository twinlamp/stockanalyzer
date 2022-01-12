require "httparty"
require "nokogiri"

module Estimize
  include HTTParty
  base_uri "https://www.estimize.com/"

  def self.get_earnings(ticker)
    page = self.get("https://www.estimize.com/#{ticker}", verify: false)
    parsed = Nokogiri::HTML(page.body)
    return [] if page.code == 404
    byebug
    data = parsed.search("script").text.scan(/"releases":(.*),"all_releases":/)[0][0].gsub(/\"/,'').gsub(/},{/,'},,,{').gsub(/\\/,'').split(',,,')
    hash_data = data.map do |earning|
      hash = {}
      earning[2..-2].gsub(/,(\D)/, '%%%\1').gsub(/(\D),/, '\1%%%').split('%%%').each do |el|
        key, value = el.split(':')
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
      Earning.new(params) if ( !params[:eps].nil? && params[:report] < Date.today )
    end
  end
end