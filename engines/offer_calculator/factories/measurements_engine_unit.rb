# frozen_string_literal: true

FactoryBot.define do
  factory :measurements_engine_unit, class: "OfferCalculator::Service::Measurements::Engines::Unit" do
    skip_create
    cargo_unit { FactoryBot.create(:journey_cargo_unit) }
    manipulated_result { FactoryBot.build(:manipulator_result) }
    scope { {} }

    initialize_with do
      OfferCalculator::Service::Measurements::Engines::Unit.new(
        cargo_unit: cargo_unit,
        scope: scope,
        object: manipulated_result
      )
    end
  end
end
