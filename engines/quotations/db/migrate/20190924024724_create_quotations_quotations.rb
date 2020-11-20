# frozen_string_literal: true

class CreateQuotationsQuotations < ActiveRecord::Migration[5.2]
  def change
    create_table :quotations_quotations, id: :uuid do |t|
      t.references :user
      t.uuid :tenant_id, index: true, foreign_key: {to_table: :tenants_tenants}
      t.integer :origin_nexus_id, index: true, foreign_key: {to_table: :nexuses}
      t.integer :destination_nexus_id, index: true, foreign_key: {to_table: :nexuses}
      t.datetime :selected_date
      t.belongs_to :sandbox

      t.timestamps
    end
  end
end
