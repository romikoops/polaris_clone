# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_charge_categories, class: 'Legacy::ChargeCategory' do
    name { 'Grand Total' }
    code { 'grand_total' }
    cargo_unit_id { nil }
    association :tenant, factory: :legacy_tenant

    trait :bas do
      name { 'Basic Ocean Freight' }
      code { 'bas' }
    end

    trait :solas do
      name { 'SOLAS FEE' }
      code { 'solas' }
    end

    trait :baf do
      name { 'Bunker Adjustment Fee' }
      code { 'baf' }
    end

    trait :thc do
      name { 'Terminal Handling Cost' }
      code { 'thc' }
    end

    trait :has do
      name { 'Heavy Weight Freight' }
      code { 'has' }
    end

    trait :puf do
      name { 'Pick Up Fee' }
      code { 'puf' }
    end

    trait :export do
      name { 'Export Charges' }
      code { 'export' }
    end

    trait :import do
      name { 'Import Charges' }
      code { 'import' }
    end

    trait :cargo do
      name { 'Freight Charges' }
      code { 'cargo' }
    end

    trait :trucking_pre do
      name { 'Trucking' }
      code { 'trucking_pre' }
    end

    trait :trucking_on do
      name { 'Trucking' }
      code { 'trucking_on' }
    end

    to_create do |instance|
      instance.attributes = Legacy::ChargeCategory.create_with(code: instance.code)
                                                  .find_or_create_by(
                                                    tenant: instance.tenant,
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

# == Schema Information
#
# Table name: charge_categories
#
#  id            :bigint           not null, primary key
#  code          :string
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  cargo_unit_id :integer
#  sandbox_id    :uuid
#  tenant_id     :integer
#
# Indexes
#
#  index_charge_categories_on_cargo_unit_id  (cargo_unit_id)
#  index_charge_categories_on_code           (code)
#  index_charge_categories_on_sandbox_id     (sandbox_id)
#  index_charge_categories_on_tenant_id      (tenant_id)
#
