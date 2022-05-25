# frozen_string_literal: true

FactoryBot.define do
  factory :distributions_action, class: "Distributions::Action" do
    association :organization, factory: :organizations_organization
    association :target_organization, factory: :organizations_organization
    upload_schema { "grdb_excel" }

    trait :add_fee do
      action_type { "add_fee" }
      where { { "origin_locode" => "DEHAM" } }
      arguments { { fee_code: "export customs", fee_name: "Export Customs", currency: "EUR", rate: 35, rate_basis: "PER_SHIPMENT" } }
    end

    trait :add_values do
      action_type { "add_values" }
      where { { "origin_locode" => "DEHAM" } }
      arguments { { "dangerous" => false } }
    end

    trait :duplicate do
      action_type { "duplicate" }
      where { { "origin_locode" => "DEHAM" } }
      arguments { {} }
    end

    trait :adjust_fee do
      action_type { "adjust_fee" }
      where { { "fee_code" => "bas" } }
      arguments { { "operator" => "%", "value" => 0.15 } }
    end
  end
end
