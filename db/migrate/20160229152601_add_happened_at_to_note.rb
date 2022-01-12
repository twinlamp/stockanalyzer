class AddHappenedAtToNote < ActiveRecord::Migration[5.1]
  def change
    add_column :notes, :happened_at, :date
  end
end
