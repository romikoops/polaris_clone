# frozen_string_literal: true

FactoryBot.define do
  factory :rate_builder_result, class: "OfferCalculator::Service::RateBuilders::Result" do
    skip_create
    object { {} }
    measures { {} }

    initialize_with do
      OfferCalculator::Service::RateBuilders::Result.new(
        object: object,
        measures: measures
      )
    end

    after(:build) do |result, _evaluator|
      result.object.fees.each do |fee_key, fee_data|
        charge_category = Legacy::ChargeCategory.from_code(
          organization_id: result.object.organization.id, code: fee_key
        )
        rate_basis = fee_data.dig("rate_basis")
        result.fees << FactoryBot.build(:rate_builder_fee,
          charge_category: charge_category,
          measures: result.measures.targets.first,
          raw_fee: fee_data,
          targets: rate_basis == "PER_SHIPMENT" ? [] : result.measures.targets.first.cargo_units)
      end
    end
  end
end
