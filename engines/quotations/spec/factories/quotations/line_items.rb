# frozen_string_literal: true

FactoryBot.define do
  factory :quotations_line_item, class: 'Quotations::LineItem' do
    amount_cents { 30 }
    amount_currency { 'USD' }
    association :tender, factory: :quotations_tender
    association :charge_category, factory: :legacy_charge_categories
  end
end
