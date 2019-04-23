# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_user, class: 'Tenants::User' do
    transient do
      activate { true }
    end

    sequence(:email) { |n| "test#{n}@itsmycargo.test" }

    after(:create) do |user, evaluator|
      user.activate! if evaluator.activate

      FactoryBot.create(:tenants_scope, target: user)
    end
  end
end
