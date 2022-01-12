class AddEarningsCountToStocks < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :earnings_count, :integer
  end
end
