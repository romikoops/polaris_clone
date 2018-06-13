# frozen_string_literal: true

class UpdateIncotermModels < ActiveRecord::Migration[5.1]
  def change
    add_column :incoterm_charges, :origin_warehousing, :boolean
    add_column :incoterm_charges, :origin_labour, :boolean
    add_column :incoterm_charges, :origin_packing, :boolean
    add_column :incoterm_charges, :origin_loading, :boolean
    add_column :incoterm_charges, :origin_customs, :boolean
    add_column :incoterm_charges, :origin_port_charges, :boolean
    add_column :incoterm_charges, :forwarders_fee, :boolean
    add_column :incoterm_charges, :origin_vessel_loading, :boolean
    add_column :incoterm_charges, :destination_port_charges, :boolean
    add_column :incoterm_charges, :destination_customs, :boolean
    add_column :incoterm_charges, :destination_loading, :boolean
    add_column :incoterm_charges, :destination_labour, :boolean
    add_column :incoterm_charges, :destination_warehousing, :boolean
    add_column :incoterm_liabilities, :origin_warehousing, :boolean
    add_column :incoterm_liabilities, :origin_labour, :boolean
    add_column :incoterm_liabilities, :origin_packing, :boolean
    add_column :incoterm_liabilities, :origin_loading, :boolean
    add_column :incoterm_liabilities, :origin_customs, :boolean
    add_column :incoterm_liabilities, :origin_port_charges, :boolean
    add_column :incoterm_liabilities, :forwarders_fee, :boolean
    add_column :incoterm_liabilities, :origin_vessel_loading, :boolean
    add_column :incoterm_liabilities, :destination_port_charges, :boolean
    add_column :incoterm_liabilities, :destination_customs, :boolean
    add_column :incoterm_liabilities, :destination_loading, :boolean
    add_column :incoterm_liabilities, :destination_labour, :boolean
    add_column :incoterm_liabilities, :destination_warehousing, :boolean
    add_column :incoterm_scopes, :mode_of_transport, :boolean
    remove_column :incoterm_liabilities, :destination, :boolean
    remove_column :incoterm_liabilities, :origin, :boolean
    remove_column :incoterm_charges, :destination, :boolean
    remove_column :incoterm_charges, :origin, :boolean
    remove_column :incoterms, :incoterm_scope_id, :integer
    remove_column :incoterms, :incoterm_liability_id, :integer
    remove_column :incoterms, :incoterm_charge_id, :integer
    add_column :incoterms, :seller_incoterm_scope_id, :integer
    add_column :incoterms, :seller_incoterm_liability_id, :integer
    add_column :incoterms, :seller_incoterm_charge_id, :integer
    add_column :incoterms, :buyer_incoterm_scope_id, :integer
    add_column :incoterms, :buyer_incoterm_liability_id, :integer
    add_column :incoterms, :buyer_incoterm_charge_id, :integer
  end
end
