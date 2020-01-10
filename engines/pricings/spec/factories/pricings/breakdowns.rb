# frozen_string_literal: true

FactoryBot.define do
  factory :pricings_breakdown, class: 'Pricings::Breakdown' do
    charge_category_id { FactoryBot.create(:legacy_charge_categories).id }
  end
end
