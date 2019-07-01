# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_user, class: 'Legacy::User' do
    sequence(:email) { |n| "demo#{n}@itsmycargo.test" }
    association :tenant, factory: :legacy_tenant
    first_name { 'John' }
    last_name { 'Smith' }
    sandbox { false }
  end
end
