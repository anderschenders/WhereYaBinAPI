class AddLngColumnToUserBin < ActiveRecord::Migration[5.1]
  def change
    add_column :user_bins, :user_lng, :float
  end
end
