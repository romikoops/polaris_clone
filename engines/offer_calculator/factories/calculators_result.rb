# frozen_string_literal: true

FactoryBot.define do
  factory :calculators_result, class: "OfferCalculator::Service::Calculators::Result" do
    skip_create
    object { {} }
    measures { {} }
    transient do
      rate_builder_result {}
    end

    initialize_with do
      OfferCalculator::Service::Calculators::Result.new(
        object: object,
        measures: measures
      )
    end

    after(:build) do |result, evaluator|
      evaluator.rate_builder_result&.fees&.each do |fee|
        result.charges << FactoryBot.build(:calculators_charge,
          value: fee.components.first.value * fee.measures.send(fee.components.first.modifier)&.value,
          fee: fee,
          fee_component: fee.components.first)
      end
    end
  end
end
