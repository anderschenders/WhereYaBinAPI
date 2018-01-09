class AddColumnToUserBin < ActiveRecord::Migration[5.1]
  def change
    add_column :user_bins, :user_lat, :float
  end
end
