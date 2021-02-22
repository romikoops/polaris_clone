# frozen_string_literal: true
FactoryBot.define do
  factory :journey_offer_result, class: "Journey::OfferResult" do
    association :result, factory: :journey_result
    association :offer, factory: :journey_offer
  end
end
