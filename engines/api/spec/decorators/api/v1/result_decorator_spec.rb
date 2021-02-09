# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ResultDecorator do
  let!(:result) { FactoryBot.build(:journey_result) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:scope) { Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }
  let(:decorated_query) { described_class.new(result, context: {scope: scope}) }
  let(:legacy_json) { decorated_query.legacy_json }
  let(:note) { FactoryBot.create(:legacy_note) }
  let(:note_service_dummy) { double("Notes::Service", fetch: [note]) }
  let(:query) { result.query }
  let(:metadatum) { FactoryBot.create(:pricings_metadatum, result_id: result.id) }
  let(:pricing) { FactoryBot.create(:pricings_pricing, organization: organization) }
  let!(:line_item) { FactoryBot.create(:journey_line_item, route_section: result.route_sections.first) }
  let(:base_keys) do
    %i[
      id
      status
      load_type
      planned_pickup_date
      has_pre_carriage
      has_on_carriage
      destination_nexus
      origin_nexus
      origin_hub
      destination_hub
      planned_eta
      planned_etd
      cargo_count
      client_name
      booking_placed_at
      imc_reference
    ]
  end

  before do
    FactoryBot.create(:pricings_breakdown,
      metadatum: metadatum,
      rate_origin: {type: "Pricings::Pricing", id: pricing.id},
      order: 0,
      line_item_id: line_item.id)
    allow(Notes::Service).to receive(:new).and_return(note_service_dummy)
    FactoryBot.create(:treasury_exchange_rate, from: "EUR", to: "USD")
  end

  describe ".legacy_json" do
    let(:expected_keys) { base_keys }
    let(:itinerary) { pricing.itinerary }
    let(:origin_hub) { itinerary.origin_hub }
    let(:destination_hub) { itinerary.destination_hub }
    let(:origin_nexus) { origin_hub.nexus }
    let(:destination_nexus) { destination_hub.nexus }

    it "returns the legacy response format" do
      aggregate_failures do
        expect(legacy_json.keys).to match_array(expected_keys)
        expect(legacy_json[:id]).to eq(result.id)
        expect(legacy_json[:status]).to eq("quoted")
        expect(legacy_json[:load_type]).to eq("cargo_item")
        expect(legacy_json[:planned_pickup_date]).to eq(query.cargo_ready_date)
        expect(legacy_json[:has_pre_carriage]).to eq(false)
        expect(legacy_json[:has_on_carriage]).to eq(false)
        expect(legacy_json[:destination_nexus]["id"]).to eq(destination_nexus.id)
        expect(legacy_json[:origin_nexus]["id"]).to eq(origin_nexus.id)
        expect(legacy_json[:origin_hub]).to eq(origin_hub)
        expect(legacy_json[:destination_hub]).to eq(destination_hub)
        expect(legacy_json[:planned_eta]).to eq(query.delivery_date)
        expect(legacy_json[:planned_etd]).to eq(query.cargo_ready_date)
        expect(legacy_json[:cargo_count]).to eq(query.cargo_units.count)
        expect(legacy_json[:client_name]).to eq(query.client.profile.full_name)
        expect(legacy_json[:booking_placed_at]).to eq(query.created_at)
        expect(legacy_json[:imc_reference]).to be_present
      end
    end
  end

  context "with addresses" do
    before do
      Geocoder::Lookup::Test.add_stub([query.origin_coordinates.y, query.origin_coordinates.x], [
        "address_components" => [{"types" => ["premise"]}],
        "address" => query.origin,
        "city" => "",
        "country" => "",
        "country_code" => factory_country_from_code(code: "SE").code,
        "postal_code" => ""
      ])
    end

    describe ".legacy_address_json" do
      let(:legacy_address_json) { decorated_query.legacy_address_json }
      let(:expected_keys) { base_keys + %i[pickup_address delivery_address selected_offer] }

      before do
        result.route_sections << FactoryBot.build(:journey_route_section, order: 0, mode_of_transport: "carriage")
        result.save
      end

      it "returns the legacy response format for displaying addresses and offer" do
        aggregate_failures do
          expect(legacy_address_json.keys).to match_array(expected_keys)
          expect(legacy_address_json.dig(:pickup_address, "latitude")).to eq(query.origin_coordinates.y)
          expect(legacy_address_json.dig(:pickup_address, "longitude")).to eq(query.origin_coordinates.x)
        end
      end
    end

    describe ".legacy_index_json" do
      let(:legacy_index_json) { decorated_query.legacy_index_json }
      let(:expected_keys) { base_keys + %i[pickup_address delivery_address] }

      it "returns the legacy response format for the index list" do
        aggregate_failures do
          expect(legacy_index_json.keys).to match_array(expected_keys)
        end
      end
    end
  end
end
