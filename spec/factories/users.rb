# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    currency { 'USD' }
    sequence(:email) { |n| "demo#{n}@demo.com" }
    password { 'demo123456789' }
    association :organization, factory: :organizations_organization
    association :role

    transient do
      with_profile { false }
      first_name { 'Guest' }
      last_name { 'User' }
    end

    after(:create) do |user, evaluator|
      evaluator.with_profile && create(:profiles_profile,
                                       first_name: evaluator.first_name,
                                       last_name: evaluator.last_name,
                                       user_id: Tenants::User.find_by(legacy_id: user.id).id)
    end
  end
end
