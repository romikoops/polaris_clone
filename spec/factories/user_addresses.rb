# frozen_string_literal: true

FactoryBot.define do
  factory :user_addresses, class: 'UserAddress' do
    association :user
    association :address
  end
end
