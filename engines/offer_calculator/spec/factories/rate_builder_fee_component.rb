# frozen_string_literal: true

FactoryBot.define do
  factory :rate_builder_fee_component, class: "OfferCalculator::Service::RateBuilders::FeeComponent" do
    skip_create
    value { {} }
    modifier { {} }
    base { {} }

    initialize_with do
      OfferCalculator::Service::RateBuilders::FeeComponent.new(
        value: value,
        modifier: modifier,
        base: base
      )
    end
  end
end
