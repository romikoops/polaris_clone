# frozen_string_literal: true

FactoryBot.define do
  factory :journey_offer_line_item_set, class: "Journey::OfferLineItemSet" do
    association :line_item_set, factory: :journey_line_item_set
    association :offer, factory: :journey_offer
  end
end
