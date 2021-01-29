# frozen_string_literal: true

FactoryBot.define do
  factory :measurements_cargo, class: "OfferCalculator::Service::Measurements::Cargo" do
    skip_create
    engine { FactoryBot.build(:measurements_engine_unit, manipulated_result: manipulated_result) }
    manipulated_result { FactoryBot.build(:manipulator_result) }

    transient do
      cargo_trait { :lcl }
    end

    initialize_with do
      OfferCalculator::Service::Measurements::Cargo.new(
        engine: engine,
        scope: scope,
        object: manipulated_result
      )
    end
  end
end
