# frozen_string_literal: true

FactoryBot.define do
  factory :rate_builder_fee, class: "OfferCalculator::Service::RateBuilders::Fee" do
    skip_create
    min_value { Money.new(0, "USD") }
    max_value { Money.new(1e12, "USD") }
    rate_basis { {} }
    charge_category { {} }
    targets { [] }
    measures { {} }
    transient do
      raw_fee {}
    end
    Struct.new("FeeInputs", :charge_category, :rate_basis, :min_value, :max_value, :measures, :targets)
    initialize_with do
      fee_inputs = Struct::FeeInputs.new(
        charge_category,
        rate_basis,
        min_value,
        max_value,
        measures,
        targets
      )
      OfferCalculator::Service::RateBuilders::Fee.new(inputs: fee_inputs)
    end

    after(:build) do |fee, evaluator|
      if evaluator.raw_fee
        modifier_lookup = OfferCalculator::Service::RateBuilders::Base::MODIFIERS_BY_RATE_BASIS
        raw_fee = evaluator.raw_fee.with_indifferent_access
        rate_basis = raw_fee["rate_basis"]
        if rate_basis == "PER_CBM_TON"
          fee.components << FactoryBot.build(:rate_builder_fee_component,
            value: raw_fee.dig("cbm"),
            modifier: "cbm",
            base: raw_fee.dig("base"))
          fee.components << FactoryBot.build(:rate_builder_fee_component,
            value: raw_fee.dig("ton"),
            modifier: "ton",
            base: raw_fee.dig("base"))
        elsif raw_fee["range"].present?
          value = raw_fee.dig(:range, 0, :value) || raw_fee.dig("range", 0, "rate")
          fee.components << FactoryBot.build(:rate_builder_fee_component,
            value: Money.new(value * 100.0, raw_fee.dig("currency")),
            modifier: modifier_lookup.find { |_key, modifiers| modifiers.include?(rate_basis) }.first,
            base: raw_fee.dig("base"))
        else
          value = raw_fee.dig(:value) || raw_fee.dig(:rate)
          fee.components << FactoryBot.build(:rate_builder_fee_component,
            value: Money.new(value * 100.0, raw_fee.dig("currency")),
            percentage: value,
            modifier: modifier_lookup.find { |_key, modifiers| modifiers.include?(rate_basis) }.first,
            base: raw_fee.dig("base"))
        end
      end
    end
  end
end
