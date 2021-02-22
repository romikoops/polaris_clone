# frozen_string_literal: true
FactoryBot.define do
  factory :treasury_exchange_rate, class: "Treasury::ExchangeRate" do
    from { "USD" }
    to { "EUR" }
    rate { 1.26 }
  end
end
