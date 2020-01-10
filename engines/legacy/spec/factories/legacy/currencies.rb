# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_currency, class: 'Legacy::Currency' do
    base { 'EUR' }
    today { { 'EUR' => 1, 'USD' => 1.120454 } }
    updated_at { Date.current }
  end
end
