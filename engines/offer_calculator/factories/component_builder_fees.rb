# frozen_string_literal: true

FactoryBot.define do
  factory :component_builder_fee, class: "Hash" do
    skip_create
    data { {} }

    initialize_with do
      data.with_indifferent_access
    end

    trait :stowage do
      data do
        {
          "key" => "QDF",
          "max" => nil,
          "min" => 5,
          "name" => "Wharfage / Quay Dues",
          "range" => [
            { "max" => 5, "min" => 0, "ton" => 41, "currency" => "EUR" },
            { "cbm" => 8, "max" => 40, "min" => 6, "currency" => "EUR" }
          ],
          "currency" => "EUR",
          "rate_basis" => "PER_UNIT_TON_CBM_RANGE"
        }
      end
    end
    trait :dynamic do
      data do
        {
          "key" => "QDF",
          "max" => nil,
          "min" => 5,
          "name" => "Wharfage / Quay Dues",
          "cbm" => 10,
          "ton" => 20,
          "currency" => "EUR",
          "rate_basis" => "PER_CBM_TON"
        }
      end
    end
    trait :percentage do
      data do
        {
          "key" => "FSC",
          "max" => nil,
          "min" => 5,
          "name" => "Fuel Surcharge",
          "percentage" => 0.325,
          "currency" => "EUR",
          "rate_basis" => "PERCENTAGE"
        }
      end
    end
    trait :rate_percentage do
      data do
        {
          "key" => "FSC",
          "max" => nil,
          "min" => 5,
          "name" => "Fuel Surcharge",
          "rate" => 0.325,
          "currency" => "EUR",
          "rate_basis" => "PERCENTAGE"
        }
      end
    end
    trait :maximum_minimum do
      data do
        {
          "key" => "FSC",
          "maximum" => 100,
          "minimum" => 5,
          "name" => "Fuel Surcharge",
          "percentage" => 0.325,
          "currency" => "EUR",
          "rate_basis" => "PERCENTAGE"
        }
      end
    end
    trait :ton do
      data do
        {
          "key" => "FSC",
          "max" => nil,
          "min" => 5,
          "name" => "Fuel Surcharge",
          "ton" => 0.325,
          "currency" => "EUR",
          "rate_basis" => "PER_TON"
        }
      end
    end
  end
end
