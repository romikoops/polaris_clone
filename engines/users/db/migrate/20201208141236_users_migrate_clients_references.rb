# frozen_string_literal: true
class UsersMigrateClientsReferences < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      remove_foreign_keys
    end
  end

  def remove_foreign_keys
    remove_foreign_key :address_book_contacts, column: :user_id
    remove_foreign_key :booking_offers, column: :shipper_id
    remove_foreign_key :booking_queries, column: :customer_id
    remove_foreign_key :contacts, column: :user_id
    remove_foreign_key :journey_queries, column: :client_id
    remove_foreign_key :journey_queries, column: :creator_id
    remove_foreign_key :journey_shipment_requests, column: :client_id
    remove_foreign_key :local_charges, column: :user_id
    remove_foreign_key :pricings_pricings, column: :user_id
    remove_foreign_key :quotations, column: :user_id
    remove_foreign_key :quotations_quotations, column: :user_id
    remove_foreign_key :shipments, column: :user_id
    remove_foreign_key :shipments_shipment_requests, column: :user_id
    remove_foreign_key :shipments_shipments, column: :user_id
    remove_foreign_key :trucking_truckings, column: :user_id
    remove_foreign_key :user_addresses, column: :user_id
    remove_foreign_key :user_managers, column: :user_id
    remove_foreign_key :users_authentications, column: :user_id
  end

  def add_foreign_keys
    add_foreign_key :address_book_contacts, :users_clients, column: :user_id, on_delete: :cascade
    add_foreign_key :booking_offers, :users_clients, column: :shipper_id, on_delete: :cascade
    add_foreign_key :booking_queries, :users_clients, column: :customer_id, on_delete: :cascade
    add_foreign_key :contacts, :users_clients, column: :user_id, on_delete: :cascade
    add_foreign_key :journey_queries, :users_clients, column: :client_id, on_delete: :cascade
    add_foreign_key :journey_shipment_requests, :users_clients, column: :client_id, on_delete: :cascade
    add_foreign_key :local_charges, :users_clients, column: :user_id, on_delete: :cascade
    add_foreign_key :pricings_pricings, :users_clients, column: :user_id, on_delete: :cascade
    add_foreign_key :quotations, :users_clients, column: :user_id, on_delete: :cascade
    add_foreign_key :quotations_quotations, :users_clients, column: :user_id, on_delete: :cascade
    add_foreign_key :shipments, :users_clients, column: :user_id, on_delete: :cascade
    add_foreign_key :shipments_shipment_requests, :users_clients, column: :user_id, on_delete: :cascade
    add_foreign_key :shipments_shipments, :users_clients, column: :user_id, on_delete: :cascade
    add_foreign_key :trucking_truckings, :users_clients, column: :user_id, on_delete: :cascade
    add_foreign_key :user_addresses, :users_clients, column: :user_id, on_delete: :cascade
    add_foreign_key :user_managers, :users_clients, column: :user_id, on_delete: :cascade
    add_foreign_key :users_authentications, :users_clients, column: :user_id, on_delete: :cascade
  end
end
