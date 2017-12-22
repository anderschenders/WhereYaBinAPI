class FixColumnName < ActiveRecord::Migration[5.1]
  def change
    rename_column :bins, :type, :bin_type
  end
end
