class AddOrderIndexToRemarks < ActiveRecord::Migration[5.2]
  def change
    add_column :remarks, :order, :integer
  end
end
