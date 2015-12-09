class AddLastSplitDateToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :last_split_date, :datetime
  end
end
