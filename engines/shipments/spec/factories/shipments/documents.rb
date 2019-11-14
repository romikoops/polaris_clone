# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_document, class: 'Shipments::Document' do
    trait :request_doc do
      attachable { |a| a.association(:shipments_shipment_request) }
    end

    trait :shipment_doc do
      attachable { |a| a.association(:shipments_shipment) }
    end
  end
end
