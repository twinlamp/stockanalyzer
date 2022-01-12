class RemoveEarningIdFromNotes < ActiveRecord::Migration[5.1]
  def change
    remove_column :notes, :earning_id, :integer
  end
end
