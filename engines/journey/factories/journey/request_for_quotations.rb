# frozen_string_literal: true

FactoryBot.define do
  factory :request_for_quotation, class: "Journey::RequestForQuotation" do
    full_name { "John Doe" }
    phone { "+49-67686960" }
    email { "john.doe@example.com" }
    company_name { "abc cargo" }
    note { "quotation required" }
    association :organization, factory: :organizations_organization
    association :query, factory: :journey_query
  end
end
