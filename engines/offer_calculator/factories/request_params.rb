# frozen_string_literal: true

FactoryBot.define do
  factory :journey_request_params, class: "Hash" do
    skip_create

    container_attributes { [] }
    cargo_items_attributes { [] }
    pickup_address {}
    pickup_truck_type {}
    delivery_address {}
    delivery_truck_type {}
    origin_hub {}
    destination_hub {}
    origin {}
    destination {}
    direction { "export" }
    selected_day { 4.days.from_now.beginning_of_day.to_s }
    aggregated_cargo_attributes { [] }
    cargo_item_type_id {}
    load_type { "container" }
    async { false }

    trait :lcl do
      cargo_item_type_id { FactoryBot.create(:legacy_cargo_item_type).id }
      cargo_items_attributes do
        [
          {
            payload_in_kg: 120,
            total_volume: 0,
            total_weight: 0,
            width: 120,
            length: 80,
            height: 120,
            quantity: 1,
            cargo_item_type_id: cargo_item_type_id,
            dangerous_goods: false,
            stackable: true
          }
        ]
      end
      load_type { "cargo_item" }
    end

    trait :fcl do
      container_attributes do
        [
          {
            payload_in_kg: 12_000,
            size_class: "fcl_20",
            quantity: 1,
            dangerous_goods: false
          },
          {
            payload_in_kg: 12_000,
            size_class: "fcl_40",
            quantity: 1,
            dangerous_goods: false
          },
          {
            payload_in_kg: 12_000,
            size_class: "fcl_40_hq",
            quantity: 1,
            dangerous_goods: false
          }
        ]
      end
      load_type { "container" }
    end

    initialize_with do
      {
        selected_day: selected_day,
        cargo_items_attributes: cargo_items_attributes,
        containers_attributes: attributes[:container_attributes],
        trucking: {
          pre_carriage: {
            address_id: pickup_address&.id,
            truck_type: pickup_truck_type
          },
          on_carriage: {
            address_id: delivery_address&.id,
            truck_type: delivery_truck_type
          }
        },
        origin: {
          id: origin&.id,
          latitude: pickup_address&.latitude,
          longitude: pickup_address&.longitude,
          nexus_name: origin_hub&.nexus&.name,
          nexus_id: origin_hub&.nexus_id,
          country: (origin_hub&.address || pickup_address)&.country&.code,
          full_address: pickup_address&.geocoded_address
        },
        destination: {
          id: destination&.id,
          latitude: delivery_address&.latitude,
          longitude: delivery_address&.longitude,
          nexus_name: destination_hub&.nexus&.name,
          nexus_id: destination_hub&.nexus_id,
          country: (destination_hub&.address || delivery_address)&.country&.code,
          full_address: delivery_address&.geocoded_address
        },
        incoterm: {},
        aggregated_cargo_attributes: aggregated_cargo_attributes,
        load_type: load_type,
        async: async
      }
    end
  end
end
