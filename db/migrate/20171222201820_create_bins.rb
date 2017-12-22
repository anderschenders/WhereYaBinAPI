class CreateBins < ActiveRecord::Migration[5.1]
  def change
    create_table :bins do |t|
      t.string :type
      t.float :latitude
      t.float :longitude
      t.string :created_by

      t.timestamps
    end
  end
end
