# frozen_string_literal: true

FactoryBot.define do
  factory :api_query, class: "Api::Query", parent: :journey_query do
    organization { association(:organizations_organization) }
  end
end
