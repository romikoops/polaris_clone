class CreateRmsDataCells < ActiveRecord::Migration[5.2]
  def change
    create_table :rms_data_cells, id: :uuid do |t|
      t.uuid :tenant_id, index: true
      t.integer :row, index: true
      t.integer :column, index: true
      t.string :value
      t.uuid :sheet_id, index: true
      t.timestamps
    end
  end
end
