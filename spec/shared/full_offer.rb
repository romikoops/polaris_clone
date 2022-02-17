# frozen_string_literal: true

require_relative "./basic_setup"
require_relative "./complete_route_with_trucking"

RSpec.shared_context "full_offer" do
  let(:cargo_classes) { %w[fcl_20 fcl_40 fcl_40_hq] }
  include_context "offer_calculator_shared_context"
  include_context "complete_route_with_trucking"
  let(:request_params) do
    FactoryBot.build(:journey_request_params,
      cargo_trait,
      origin_hub: origin_hub,
      destination_hub: destination_hub,
      pickup_address: pickup_address,
      delivery_address: delivery_address)
  end
  let(:query) do
    FactoryBot.create(:journey_query,
      organization: organization,
      client: client,
      creator: client,
      load_type: cargo_trait,
      cargo_count: 0,
      origin_coordinates: pickup_address&.geo_point || origin_hub.point,
      destination_coordinates: delivery_address&.geo_point || destination_hub.point)
  end
  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:request) do
    FactoryBot.build(:offer_calculator_request,
      params: request_params,
      query: query,
      cargo_trait: cargo_trait,
      pre_carriage: pre_carriage,
      on_carriage: on_carriage,
      organization: organization)
  end
  let(:pre_carriage) { true }
  let(:on_carriage) { true }
  let(:load_type) { "container" }
  let(:cargo_trait) { load_type == "container" ? :fcl : :lcl }
  let(:schedules) { trips.map { |trip| OfferCalculator::Schedule.from_trip(trip) } }
  let(:calculator_results) do
    (pricings | local_charges | truckings).flat_map do |object|
      FactoryBot.build(:calculators_result_from_raw,
        raw_object: object,
        request: request)
    end
  end
  let(:offer) do
    OfferCalculator::Service::OfferCreators::Offer.new(
      request: request,
      schedules: schedules,
      offer: calculator_results.group_by(&:section)
    )
  end

  before do
    Geocoder::Lookup::Test.add_stub([query.destination_coordinates.y, query.destination_coordinates.x], [
      "address_components" => [{ "types" => ["premise"] }],
      "address" => "Shanghai, China",
      "city" => "Shanghai",
      "country" => "China",
      "country_code" => "CN",
      "postal_code" => "210001"
    ])
    Geocoder::Lookup::Test.add_stub([query.origin_coordinates.y, query.origin_coordinates.x], [
      "address_components" => [{ "types" => ["premise"] }],
      "address" => "Hamburg, Germany",
      "city" => "Hamburg",
      "country" => "Germany",
      "country_code" => "DE",
      "postal_code" => "20457"
    ])
  end
end
