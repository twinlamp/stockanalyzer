class AddTimestampsToNote < ActiveRecord::Migration[5.1]
  def change
    add_column :notes, :created_at, :datetime
    add_column :notes, :updated_at, :datetime
  end
end
