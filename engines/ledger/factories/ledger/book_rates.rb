# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_book_rate, class: "Ledger::BookRate" do
    association :book, factory: :ledger_book
    association :rate, factory: :ledger_rate
  end
end
