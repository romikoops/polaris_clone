# frozen_string_literal: true
FactoryBot.define do
  factory :journey_commodity_info, class: "Journey::CommodityInfo" do
    association :cargo_unit, factory: :journey_cargo_unit
    hs_code { "9504.90.60.00" }
    imo_class { "2.1" }
    description { "A box of masks" }
  end
end
