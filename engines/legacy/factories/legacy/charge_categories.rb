# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_charge_categories, class: "Legacy::ChargeCategory" do
    name { "Grand Total" }
    code { "grand_total" }
    cargo_unit_id { nil }
    association :organization, factory: :organizations_organization

    trait :bas do
      name { "Basic Ocean Freight" }
      code { "bas" }
    end

    trait :solas do
      name { "SOLAS FEE" }
      code { "solas" }
    end

    trait :baf do
      name { "Bunker Adjustment Fee" }
      code { "baf" }
    end

    trait :thc do
      name { "Terminal Handling Cost" }
      code { "thc" }
    end

    trait :has do
      name { "Heavy Weight Freight" }
      code { "has" }
    end

    trait :puf do
      name { "Pick Up Fee" }
      code { "puf" }
    end

    trait :export do
      name { "Export Charges" }
      code { "export" }
    end

    trait :import do
      name { "Import Charges" }
      code { "import" }
    end

    trait :cargo do
      name { "Freight Charges" }
      code { "cargo" }
    end

    trait :trucking_pre do
      name { "Trucking" }
      code { "trucking_pre" }
    end

    trait :trucking_on do
      name { "Trucking" }
      code { "trucking_on" }
    end

    trait :trucking_lcl do
      name { "Trucking Rate" }
      code { "trucking_lcl" }
    end

    to_create do |instance|
      instance.attributes = Legacy::ChargeCategory.create_with(code: instance.code)
        .find_or_create_by(
          organization: instance.organization,
          name: instance.name,
          cargo_unit_id: instance.cargo_unit_id
        )
        .attributes
      instance.reload
    end

    factory :bas_charge, traits: [:bas]
    factory :solas_charge, traits: [:solas]
    factory :baf_charge, traits: [:baf]
    factory :thc_charge, traits: [:thc]
    factory :has_charge, traits: [:has]
    factory :puf_charge, traits: [:puf]
    factory :cargo_charge_category, traits: [:cargo]
    factory :import_charge_category, traits: [:import]
    factory :export_charge_category, traits: [:export]
    factory :trucking_pre_charge, traits: [:trucking_pre]
    factory :trucking_on_charge, traits: [:trucking_on]
  end
end

def factory_charge_category_from(code:, organization:)
  existing_charge_category = Legacy::ChargeCategory.find_by(code: code.downcase, organization: organization)
  return existing_charge_category if existing_charge_category.present?

  FactoryBot.create(:legacy_charge_categories, code: code.downcase, name: code.upcase, organization: organization)
end

# == Schema Information
#
# Table name: charge_categories
#
#  id              :bigint           not null, primary key
#  code            :string
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cargo_unit_id   :integer
#  organization_id :uuid
#  sandbox_id      :uuid
#  tenant_id       :integer
#
# Indexes
#
#  index_charge_categories_on_cargo_unit_id    (cargo_unit_id)
#  index_charge_categories_on_code             (code)
#  index_charge_categories_on_organization_id  (organization_id)
#  index_charge_categories_on_sandbox_id       (sandbox_id)
#  index_charge_categories_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
