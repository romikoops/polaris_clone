# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_shipment_request, class: 'Shipments::ShipmentRequest' do
    association :user, factory: :tenants_user
    association :tenant, factory: :tenants_tenant
    association :tender, factory: :quotations_tender

    status { :created }
    submitted_at { Time.current }
    eori { 'eori text' }
    etd { Time.current + 1.month }
    eta { Time.current + 2.months }
    sequence(:ref_number) { |n| "#{SecureRandom.hex}#{n}" }
  end
end
