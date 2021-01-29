# frozen_string_literal: true

FactoryBot.define do
  factory :measurements_engines_consolidated, class: "OfferCalculator::Service::Measurements::Engines::Consolidated" do
    skip_create
    request { FactoryBot.create(:offer_calculator_request, params: journey_request_params) }
    scope { {} }

    transient do
      journey_request_params do
        FactoryBot.build(:journey_request_params,
          load_type: "cargo_item",
          cargo_item_attributes: cargo_item_attributes)
      end
      cargo_item_attributes do
        cargo_item_type = FactoryBot.create(:legacy_cargo_item_type)
        [
          {
            payload_in_kg: 120,
            total_volume: 0,
            total_weight: 0,
            width: 120,
            length: 80,
            height: 120,
            quantity: 1,
            cargo_item_type_id: cargo_item_type.id,
            dangerous_goods: false,
            stackable: true
          },
          {
            payload_in_kg: 120,
            total_volume: 0,
            total_weight: 0,
            width: 120,
            length: 80,
            height: 120,
            quantity: 1,
            cargo_item_type_id: cargo_item_type.id,
            dangerous_goods: false,
            stackable: true
          }
        ]
      end
    end

    initialize_with do
      OfferCalculator::Service::Measurements::Engines::Consolidated.new(
        request: request,
        scope: scope,
        object: object
      )
    end
  end
end
