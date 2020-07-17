# frozen_string_literal: true

FactoryBot.define do
  factory :calculators_result_from_raw, class: "OfferCalculator::Service::Calculators::Result" do
    skip_create
    raw_object { {} }
    cargo { {} }
    transient do
      rate_builder_result {}
    end

    initialize_with do
      object = FactoryBot.build(:manipulator_result,
        original: raw_object,
        result: raw_object.as_json)
      measures = OfferCalculator::Service::Measurements::Cargo.new(
        cargo: cargo,
        scope: {},
        object: object
      )

      rate_builder_result = FactoryBot.build(:rate_builder_result,
        object: object,
        measures: measures)
      rate_builder_result&.fees&.map do |fee|
        FactoryBot.build(:calculators_charge,
          value: fee.components.first.value * fee.measures.send(fee.components.first.modifier)&.value,
          fee: fee,
          fee_component: fee.components.first)
      end
    end
  end
end
