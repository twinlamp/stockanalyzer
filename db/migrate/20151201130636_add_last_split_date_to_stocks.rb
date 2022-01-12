class AddLastSplitDateToStocks < ActiveRecord::Migration[5.1]
  def change
    add_column :stocks, :last_split_date, :datetime
  end
end
