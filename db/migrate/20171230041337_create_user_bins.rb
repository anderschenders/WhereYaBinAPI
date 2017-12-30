class CreateUserBins < ActiveRecord::Migration[5.1]
  def change
    create_table :user_bins do |t|
      t.integer :user_id
      t.integer :bin_id
      
      t.timestamps
    end
  end
end
