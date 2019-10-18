# frozen_string_literal: true

FactoryBot.define do
  factory :quotations_line_item, class: 'LineItem' do
    amount_cents { 30 }
    amount_currency { 'USD' }
    association :tender, factory: :quotations_tender
  end
end
