# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_exchange_rate, class: "Legacy::ExchangeRate" do
    from { "USD" }
    to { "EUR" }
    rate { 1.26 }
  end
end
