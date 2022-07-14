# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_conflict, class: "Ledger::Conflict" do
    association :book, factory: :ledger_book
    association :staged_rate, factory: :ledger_rate
    association :basis_rate, factory: :ledger_rate

    trait :incoming do
      resolution { "incoming" }
    end

    trait :current do
      resolution { "current" }
    end

    trait :with_merged_rate do
      incoming
      association :basis_rate, factory: :ledger_rate
    end
  end
end
