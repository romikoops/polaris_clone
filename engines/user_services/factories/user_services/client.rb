# frozen_string_literal: true

FactoryBot.define do
  factory :user_services_client, class: "UserServices::Client", parent: :users_client do
    sequence(:email) { |n| "led.zep.#{n}@itsmycargo.test" }

    after(:create) do |user, _evaluator|
      FactoryBot.create(:groups_group, organization: user.organization).tap do |group|
        FactoryBot.create(:groups_membership, member: user, group: group)
      end
      FactoryBot.create(:companies_membership, client: user)
    end
  end
end
