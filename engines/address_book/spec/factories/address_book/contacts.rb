# frozen_string_literal: true

FactoryBot.define do
  factory :address_book_contact, class: 'AddressBook::Contact' do
    sequence(:first_name) { |n| "John#{n}" }
    sequence(:last_name) { |n| "Smith#{n}" }
    sequence(:phone) { |n| "1234567#{n}" }
    sequence(:email) { |n| "email#{n}@example.com" }

    association :user, factory: :tenants_user
  end
end
