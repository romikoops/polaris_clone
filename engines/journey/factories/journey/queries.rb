# frozen_string_literal: true

FactoryBot.define do
  factory :journey_query, class: "Journey::Query" do
    transient do
      origin_latitude { 53.545322 }
      origin_longitude { 9.9986522 }
      destination_latitude { 31.1443485 }
      destination_longitude { 121.8060843 }
      cargo_count { 1 }
      result_set_count { 0 }
    end

    association :organization, factory: :organizations_organization
    company { association :companies_company, organization: instance.organization }
    creator { association :users_client, organization: instance.organization }
    client { association :users_client, organization: instance.organization }

    cargo_units do
      Array.new(cargo_count) do
        association :journey_cargo_unit, query: instance
      end
    end

    result_sets do
      if result_set_count.zero?
        []
      else
        Array.new(result_set_count) do
          association :journey_result_set, query: instance, result_count: 1
        end
      end
    end

    source_id { SecureRandom.uuid }
    origin { "20457, Hamburg" }
    origin_coordinates { RGeo::Geos.factory(srid: 4326).point(origin_longitude, origin_latitude) }
    destination { "Shanghai Airport" }
    destination_coordinates { RGeo::Geos.factory(srid: 4326).point(destination_longitude, destination_latitude) }
    cargo_ready_date { Time.zone.tomorrow.change(usec: 0) }
    delivery_date { (Time.zone.today + 3.weeks).change(usec: 0) }
    customs { false }
    insurance { false }
    created_at { DateTime.now.change(usec: 0) }
    billable { true }
    load_type { "lcl" }
    parent { nil }
  end
end
