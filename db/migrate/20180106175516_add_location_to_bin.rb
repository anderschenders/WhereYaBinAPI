class AddLocationToBin < ActiveRecord::Migration[5.1]
  def change
    add_column :bins, :location, :integer
  end
end
