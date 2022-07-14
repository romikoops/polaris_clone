# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_book, class: "Ledger::Book" do
    sequence(:name) { |n| "Book##{n}" }
    association :user, factory: :users_user
    association :upload, factory: :ledger_upload

    trait :with_basis_book do
      association :basis_book, factory: :ledger_book
    end

    trait :published do
      aasm_state { "published" }
      published_at { Time.zone.now.change(usec: 0) }
    end
  end
end
