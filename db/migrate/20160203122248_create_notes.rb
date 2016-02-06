class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string :title
      t.text :body
      t.integer :stock_id
      t.integer :earning_id
    end
  end
end
