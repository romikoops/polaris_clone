# frozen_string_literal: true

RSpec.shared_context "journey_query" do
  let(:origin_latitude) { 57.694253 }
  let(:origin_longitude) { 11.854048 }
  let(:origin_text) { "438 80 Landvetter, Sweden" }
  let(:origin_coordinates) { RGeo::Geos.factory(srid: 4326).point(origin_longitude, origin_latitude) }
  let(:destination_latitude) { 31.232014 }
  let(:destination_longitude) { 121.4867159 }
  let(:destination_text) { "88 Henan Middle Road, Shanghai" }
  let(:destination_coordinates) { RGeo::Geos.factory(srid: 4326).point(destination_longitude, destination_latitude) }
  let(:client) { FactoryBot.build(:users_client, organization: organization) }
  let(:cargo_units) { [] }
  let(:journey_load_type) { "lcl" }
  let(:currency) { "EUR" }
  let(:query_status) { "completed" }

  let(:query) do
    FactoryBot.create(:journey_query,
      origin_coordinates: origin_coordinates,
      origin: origin_text,
      destination_coordinates: destination_coordinates,
      destination: destination_text,
      organization: organization,
      cargo_units: cargo_units,
      client: client,
      load_type: journey_load_type,
      result_count: 0,
      currency: currency,
      status: query_status,
      results: [])
  end
end
