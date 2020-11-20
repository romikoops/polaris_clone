# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_fees, class: "Hash" do
    skip_create

    initialize_with { data.with_indifferent_access }

    transient do
      min { 5 }
    end

    trait :per_unit_ton_cbm_range do
      data do
        {
          "key" => "QDF",
          "max" => nil,
          "min" => 5,
          "name" => "Wharfage / Quay Dues",
          "range" => [{"max" => 5, "min" => 0, "ton" => 41, "currency" => "EUR"},
            {"cbm" => 8, "max" => 12, "min" => 6, "currency" => "EUR"}],
          "currency" => "EUR",
          "rate_basis" => "PER_UNIT_TON_CBM_RANGE"
        }
      end
      before(:build) do |evaluator, fee|
        fee["min"] = evaluator.min
      end
    end

    trait :per_cbm_range do
      data do
        {
          "key" => "THC",
          "max" => nil,
          "min" => 5,
          "name" => "Wharfage / Quay Dues",
          "range" => [{"max" => 10.0, "min" => 0.0, "rate" => 5.0}, {"max" => 100.0, "min" => 10.0, "rate" => 10.0}],
          "currency" => "EUR",
          "rate_basis" => "PER_CBM_RANGE"
        }
      end
      before(:build) do |evaluator, fee|
        fee["min"] = evaluator.min
      end
    end

    factory :per_unit_ton_cbm_range_trucking_fee, traits: [:per_unit_ton_cbm_range]
    factory :per_cbm_range_trucking_fee, traits: [:per_cbm_range]
  end
end
