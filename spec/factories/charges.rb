FactoryBot.define do
  factory :charge do
    association :price
    association :charge_breakdown
    association :charge_category
    association :children_charge_category, factory: :charge_category
  end
end

# == Schema Information
#
# Table name: charges
#
#  id                          :bigint(8)        not null, primary key
#  parent_id                   :integer
#  price_id                    :integer
#  charge_category_id          :integer
#  children_charge_category_id :integer
#  charge_breakdown_id         :integer
#  detail_level                :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  edited_price_id             :integer
#
