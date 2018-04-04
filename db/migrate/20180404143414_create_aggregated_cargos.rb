class CreateAggregatedCargos < ActiveRecord::Migration[5.1]
  def change
    create_table :aggregated_cargos do |t|
      t.decimal :weight
      t.decimal :volume
      t.integer :shipment_id

      t.timestamps
    end
  end
end
