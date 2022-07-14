# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_book_routing, class: "Ledger::BookRouting" do
    association :book, factory: :ledger_book
    association :routing, factory: :ledger_routing
    association :service, factory: :ledger_service

    factory :ledger_staged_book_routing, class: "Ledger::StagedBookRouting" do # rubocop:disable Lint/EmptyBlock
    end

    factory :ledger_merged_book_routing, class: "Ledger::MergedBookRouting" do # rubocop:disable Lint/EmptyBlock
    end
  end
end
