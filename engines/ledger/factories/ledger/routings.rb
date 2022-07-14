# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_routing, class: "Ledger::Routing" do
    association :origin_location, factory: :ledger_location
    association :destination_location, factory: :ledger_location
  end
end
