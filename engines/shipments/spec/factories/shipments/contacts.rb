# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_contact, class: 'Shipments::Contact' do
    sequence(:first_name) { |n| "John#{n}" }
    sequence(:last_name) { |n| "Smith#{n}" }
    sequence(:phone) { |n| "1234567#{n}" }
    sequence(:email) { |n| "email#{n}@example.com" }

    company_name { 'Example Company' }
    latitude { '57.694253' }
    longitude { '11.854048' }
    post_code { '43813' }
    geocoded_address { '438 80 Landvetter, Sweden' }
    city { 'Gothenburg' }
    country_code { 'SE' }

    trait :consignee do
      contact_type { 'consignee' }
    end

    trait :consignor do
      contact_type { 'consignor' }
    end

    trait :notifyee do
      contact_type { 'notifyee' }
    end
  end
end
