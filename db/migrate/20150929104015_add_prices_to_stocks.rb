class AddPricesToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :prices, :text
  end
end
