# frozen_string_literal: true

FactoryBot.define do
  factory :journey_shipment_request, class: "Journey::ShipmentRequest" do
    association :result, factory: :journey_result
    association :company, factory: :companies_company
    association :client, factory: :users_client
    preferred_voyage { "1234" }

    with_insurance { false }
    with_customs_handling { false }
    status { "requested" }
    notes { "" }
    commercial_value_cents { 10 }
    commercial_value_currency { "eur" }
    documents { [association(:journey_document, shipment_request: instance, query_id: result.query.id)] }
    contacts { [association(:journey_contact, shipment_request: instance)] }
  end
end
