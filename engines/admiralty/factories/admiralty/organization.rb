# frozen_string_literal: true

FactoryBot.define do
  factory :admiralty_organization, class: "Admiralty::Organization", parent: :organizations_organization do
    sequence(:slug) { |n| "test_#{n}" }
    live { true }
  end
end
