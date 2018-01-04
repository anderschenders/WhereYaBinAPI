class AddBinCountColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :bin_count, :integer
  end
end
