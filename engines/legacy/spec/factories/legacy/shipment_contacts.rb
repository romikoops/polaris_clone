# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_shipment_contact, class: 'Legacy::ShipmentContact' do
    association :contact, factory: :legacy_contact
    association :shipment, factory: :legacy_shipment
    contact_type { :shipper }
  end
end
