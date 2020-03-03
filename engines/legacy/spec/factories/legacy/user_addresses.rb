# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_user_address, class: 'Legacy::UserAddress' do
    association :user, factory: :legacy_user
    association :address, factory: :legacy_address
  end
end
