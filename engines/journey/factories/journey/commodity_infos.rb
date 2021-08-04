# frozen_string_literal: true

FactoryBot.define do
  factory :journey_commodity_info, class: "Journey::CommodityInfo" do
    association :cargo_unit, factory: :journey_cargo_unit
    hs_code { "9504.90.60.00" }
    description { "A box of masks" }
    trait :imo_class do
      hs_code { nil }
      imo_class { "2.1" }
      description { "Flammable" }
    end

    trait :hs_code do
      hs_code { "9504.90.60.00" }
      imo_class { nil }
      description { "A box of masks" }
    end
  end
end
