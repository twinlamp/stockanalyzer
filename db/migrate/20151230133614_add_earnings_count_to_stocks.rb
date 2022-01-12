class AddEarningsCountToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :earnings_count, :integer
  end
end
