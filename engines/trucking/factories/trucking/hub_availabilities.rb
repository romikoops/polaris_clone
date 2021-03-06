# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_hub_availability, class: "Trucking::HubAvailability" do
    association :hub, factory: :legacy_hub
    association :type_availability, factory: :trucking_type_availability

    transient do
      custom_truck_type { nil }
      query_type { nil }
      country { nil }
    end

    trait :lcl_pre_carriage do
      association :type_availability, factory: :cargo_item_pre_carriage
      before(:create) do |availability, evaluator|
        if evaluator.custom_truck_type.present? || evaluator.query_type.present?
          availability.type_availability = FactoryBot.create(:cargo_item_pre_carriage,
            custom_query_method: evaluator.query_type,
            custom_truck_type: evaluator.custom_truck_type,
            country: evaluator.country || availability.hub.nexus.country)
        end
      end
    end

    trait :fcl_pre_carriage do
      association :type_availability, factory: :container_pre_carriage
      before(:create) do |availability, evaluator|
        if evaluator.custom_truck_type.present? || evaluator.query_type.present?
          availability.type_availability = FactoryBot.create(:container_pre_carriage,
            custom_query_method: evaluator.query_type,
            custom_truck_type: evaluator.custom_truck_type,
            country: evaluator.country || availability.hub.nexus.country)
        end
      end
    end

    trait :lcl_on_carriage do
      association :type_availability, factory: :cargo_item_on_carriage
      before(:create) do |availability, evaluator|
        if evaluator.custom_truck_type.present? || evaluator.query_type.present?
          availability.type_availability = FactoryBot.create(:cargo_item_on_carriage,
            custom_query_method: evaluator.query_type,
            custom_truck_type: evaluator.custom_truck_type,
            country: evaluator.country || availability.hub.nexus.country)
        end
      end
    end

    trait :fcl_on_carriage do
      association :type_availability, factory: :cargo_item_on_carriage
      before(:create) do |availability, evaluator|
        if evaluator.custom_truck_type.present? || evaluator.query_type.present?
          availability.type_availability = FactoryBot.create(:container_on_carriage,
            custom_query_method: evaluator.query_type,
            custom_truck_type: evaluator.custom_truck_type,
            country: evaluator.country || availability.hub.nexus.country)
        end
      end
    end

    factory :lcl_pre_carriage_availability, traits: [:lcl_pre_carriage]
    factory :fcl_pre_carriage_availability, traits: [:fcl_pre_carriage]
    factory :lcl_on_carriage_availability, traits: [:lcl_on_carriage]
    factory :fcl_on_carriage_availability, traits: [:fcl_on_carriage]
  end
end

def factory_hub_availability(load_type:, hub:, carriage:, truck_type:, query_method:, country:)
  type_availability = factory_type_availability(
    carriage: carriage,
    truck_type: truck_type,
    query_method: query_method,
    country: country
  )
  hub_availability = Trucking::HubAvailability.find_by(
    hub: hub,
    type_availability: type_availability
  )

  hub_availability ||
    FactoryBot.create(:trucking_hub_availability, hub: hub, type_availability: type_availability)
end
# == Schema Information
#
# Table name: trucking_hub_availabilities
#
#  id                   :uuid             not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  hub_id               :integer
#  sandbox_id           :uuid
#  type_availability_id :uuid
#
# Indexes
#
#  index_trucking_hub_availabilities_on_hub_id                (hub_id)
#  index_trucking_hub_availabilities_on_sandbox_id            (sandbox_id)
#  index_trucking_hub_availabilities_on_type_availability_id  (type_availability_id)
#
