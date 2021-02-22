# frozen_string_literal: true
FactoryBot.define do
  factory :journey_contact, class: "Journey::Contact" do
    association :shipment_request, factory: :journey_shipment_request
    association :original, factory: :address_book_contact
    sequence(:name) { |n| "John#{n} Smith#{n}" }
    sequence(:phone) { |n| "1234567#{n}" }
    sequence(:email) { |n| "email#{n}@example.com" }
    company_name { "ItsMyCargo Gmbh" }
    address_line_1 { "ItsMyCargo Gmbh" }
    address_line_2 { "Brooktorkai 7" }
    address_line_3 { "Block X" }
    postal_code { "20457" }
    city { "Hamburg" }
    country_code { "DE" }
  end
end
