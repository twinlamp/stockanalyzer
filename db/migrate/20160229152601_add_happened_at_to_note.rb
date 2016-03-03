class AddHappenedAtToNote < ActiveRecord::Migration
  def change
    add_column :notes, :happened_at, :date
  end
end
