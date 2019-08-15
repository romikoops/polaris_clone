class CreateRmsDataBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :rms_data_books, id: :uuid do |t|
      t.integer :sheet_type, index: true
      t.uuid :tenant_id, index: true
      t.timestamps
    end
  end
end
