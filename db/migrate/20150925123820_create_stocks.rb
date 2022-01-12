class CreateStocks < ActiveRecord::Migration[5.1]
  def change
    create_table :stocks do |t|
      t.string :ticker

      t.timestamps null: false
    end
  end
end
