# frozen_string_literal: true

FactoryBot.define do
  factory :rate_builder_fee_component, class: "OfferCalculator::Service::RateBuilders::FeeComponent" do
    skip_create
    value { {} }
    modifier { {} }
    base { {} }
    percentage { 0 }

    initialize_with do
      OfferCalculator::Service::RateBuilders::FeeComponent.new(
        value: value,
        modifier: modifier,
        base: base,
        percentage: percentage
      )
    end
  end
end
