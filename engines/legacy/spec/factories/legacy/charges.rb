# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_charge, class: 'Legacy::Charge' do
    association :price, factory: :legacy_price
    association :charge_breakdown, factory: :legacy_charge_breakdown
    association :charge_category, factory: :legacy_charge_categories
    association :children_charge_category, factory: :legacy_charge_categories
  end
end

# == Schema Information
#
# Table name: charges
#
#  id                          :bigint           not null, primary key
#  parent_id                   :integer
#  price_id                    :integer
#  charge_category_id          :integer
#  children_charge_category_id :integer
#  charge_breakdown_id         :integer
#  detail_level                :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  edited_price_id             :integer
#  sandbox_id                  :uuid
#
