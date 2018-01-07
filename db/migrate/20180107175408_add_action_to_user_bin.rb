class AddActionToUserBin < ActiveRecord::Migration[5.1]
  def change
    add_column :user_bins, :action, :string
  end
end
