class CreateEarnings < ActiveRecord::Migration[5.1]
  def change
    create_table :earnings do |t|
      t.integer :q
      t.date :report
      t.integer :y
      t.float :revenue
      t.float :eps
      t.references :stock, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
