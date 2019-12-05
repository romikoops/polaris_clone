# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_contact, class: 'Legacy::Contact' do
    association :user, factory: :legacy_user
    association :address, factory: :legacy_address
    company_name { 'Example Company' }
    sequence(:first_name) { |n| "John#{n}" }
    sequence(:last_name) { |n| "Smith#{n}" }
    sequence(:phone) { |n| "1234567#{n}" }
    sequence(:email) { |n| "email#{n}@example.com" }
  end
end
