# frozen_string_literal: true

FactoryBot.define do
  factory :charge_category do
    association :tenant
    name { 'Grand Total' }
    code { 'grand_total' }

    trait :bas do
      name { 'Basic Ocean Freight' }
      code { 'BAS' }
    end

    trait :has do
      name { 'Heavy Weight Freight' }
      code { 'HAS' }
    end
  end
end

# == Schema Information
#
# Table name: charge_categories
#
#  id            :bigint           not null, primary key
#  name          :string
#  code          :string
#  cargo_unit_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tenant_id     :integer
#  sandbox_id    :uuid
#
