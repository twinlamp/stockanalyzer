class RemoveEarningIdFromNotes < ActiveRecord::Migration
  def change
    remove_column :notes, :earning_id, :integer
  end
end
