FactoryBot.define do
  factory :charge do
    association :price
    association :charge_breakdown
    association :charge_category
    association :children_charge_category, factory: :charge_category
  end
end
