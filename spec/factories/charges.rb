# frozen_string_literal: true

FactoryBot.define do
  factory :charge do
    association :price, factory: :legacy_price
    association :charge_breakdown
    association :charge_category
    association :children_charge_category, factory: :charge_category
  end
end

# == Schema Information
#
# Table name: charges
#
#  id                          :bigint           not null, primary key
#  detail_level                :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  charge_breakdown_id         :integer
#  charge_category_id          :integer
#  children_charge_category_id :integer
#  edited_price_id             :integer
#  parent_id                   :integer
#  price_id                    :integer
#  sandbox_id                  :uuid
#
# Indexes
#
#  index_charges_on_sandbox_id  (sandbox_id)
#
