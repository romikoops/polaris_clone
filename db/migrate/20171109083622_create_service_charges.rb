class CreateServiceCharges < ActiveRecord::Migration[5.1]
  def change
    create_table :service_charges do |t|
      t.integer  :hub_id

      t.datetime :effective_date
      t.datetime :expiration_date
      t.string   :location
      t.jsonb    :terminal_handling_cbm
      t.jsonb    :terminal_handling_ton
      t.jsonb    :terminal_handling_min
      t.jsonb    :lcl_service_cbm
      t.jsonb    :lcl_service_ton
      t.jsonb    :lcl_service_min
      t.jsonb    :isps
      t.jsonb    :exp_declaration
      t.jsonb    :extra_hs_code
      t.jsonb    :doc_fee
      t.jsonb    :liner_service_fee
      t.jsonb    :vgm_fee
      t.jsonb    :security_fee
      t.jsonb    :documentation_fee
      t.jsonb    :handling_fee
      t.jsonb    :customs_clearance
      t.jsonb    :cfs_terminal_charges
      t.jsonb    :misc_fees
      t.timestamps
    end
  end
end
