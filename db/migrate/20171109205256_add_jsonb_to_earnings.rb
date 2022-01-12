class AddJsonbToEarnings < ActiveRecord::Migration[5.1]
  def change
    add_column :earnings, :extra, :jsonb
  end
end
