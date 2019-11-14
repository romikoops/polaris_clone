# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_shipment, class: 'Shipments::Shipment' do
    association :user, factory: :tenants_user
    association :tenant, factory: :tenants_tenant
    association :origin, factory: :routing_terminal
    association :destination, factory: :routing_terminal

    after(:build) do |shipment|
      shipment.consignee = FactoryBot.build(:shipments_contact, :consignee, shipment: shipment)
      shipment.consignor = FactoryBot.build(:shipments_contact, :consignor, shipment: shipment)
      shipment.invoice = FactoryBot.build(:shipments_invoice, shipment: shipment)
      shipment.cargo = FactoryBot.build(:shipments_cargo,
                                        units: [
                                          FactoryBot.build(:shipment_lcl_unit)
                                        ])
    end
  end
end
