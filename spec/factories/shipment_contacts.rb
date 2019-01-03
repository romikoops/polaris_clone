# frozen_string_literal: true

FactoryBot.define do
  factory :shipment_contact do
    association :contact
    association :shipment
    contact_type :shipper
  end
end
