# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_location, class: "Ledger::Location" do
    geodata do
      factory = RGeo::Cartesian.factory(srid: 4326)
      factory.parse_wkt(
        "MULTIPOLYGON (((0.0 0.0, 2.0 0.0, 2.0 2.0, 0.0 2.0, 0.0 0.0), " \
        "(0.5 0.5, 1.5 0.5, 1.5 1.5, 0.5 1.5, 0.5 0.5)), " \
        "((3.0 3.0, 4.0 3.0, 4.0 4.0, 3.0 4.0, 3.0 3.0)))"
      )
    end

    trait :named do
      sequence(:name) { |n| "LOC##{n}" }
      country { "DE" }
      region { "BB" }
    end
  end
end
