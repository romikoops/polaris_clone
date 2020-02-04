# frozen_string_literal: true

FactoryBot.define do
  factory :charge_category do
    association :tenant
    name { 'Grand Total' }
    code { 'grand_total' }

    trait :bas do
      name { 'Basic Ocean Freight' }
      code { 'bas' }
    end

    trait :has do
      name { 'Heavy Weight Freight' }
      code { 'has' }
    end
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
#  index_charge_categories_on_sandbox_id  (sandbox_id)
#  index_charge_categories_on_tenant_id   (tenant_id)
#
