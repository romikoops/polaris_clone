class AddVatNumberToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :vat_number, :string
  end
end
