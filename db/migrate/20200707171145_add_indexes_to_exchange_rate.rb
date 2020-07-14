class AddIndexesToExchangeRate < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :exchange_rates, :created_at, algorithm: :concurrently
  end
end
