# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_rate, class: "Ledger::Rate" do
    association :book_routing, factory: :ledger_staged_book_routing
    sequence(:validity) { |n| (100 - (n * 2)).days.ago.to_date..(100 - (n * 2) - 1).days.ago.to_date }
    rate_basis { "kg" }
    rate { Money.new(100 * 10, :eur) }
    sequence(:fee_code) { |n| "FEE_CODE###{n}" }
    sequence(:fee_name) { |n| "FEE_NAME###{n}" }
  end
end
