# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_current_book, class: "Ledger::CurrentBook" do
    association :organization, factory: :organizations_organization
    association :user, factory: :users_user
    association :book, factory: :ledger_book
  end
end
