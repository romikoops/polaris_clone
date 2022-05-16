# frozen_string_literal: true

FactoryBot.define do
  factory :api_company, class: "Api::Company", parent: :companies_company do
    organization { association(:organizations_organization) }
  end
end
