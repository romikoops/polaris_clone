# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_line_item, class: 'Shipments::LineItem' do
    association :invoice, factory: :shipments_invoice

    amount_cents { 1000 }
    fee_code { 'HAF' }
  end
end
