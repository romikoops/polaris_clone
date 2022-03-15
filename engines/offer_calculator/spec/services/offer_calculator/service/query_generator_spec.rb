# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::QueryGenerator do
  let(:persist) { true }
  let(:load_type) { "container" }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:source) { FactoryBot.create(:application) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:company) { FactoryBot.create(:companies_company, organization: organization) }
  let(:base_params) do
    {
      async: true,
      direction: "export",
      selected_day: 4.days.from_now.beginning_of_day.to_s,
      load_type: load_type
    }
  end
  let(:service) do
    described_class.new(
      params: params,
      client: user,
      creator: user,
      source: source,
      persist: persist
    )
  end
  let(:origin_hub) { FactoryBot.create(:legacy_hub, :hamburg, organization: organization) }
  let(:destination_hub) { FactoryBot.create(:legacy_hub, :shanghai, organization: organization) }
  let(:origin_response) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.hub_code, latitude: origin_hub.latitude, longitude: origin_hub.longitude) }
  let(:destination_response) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.hub_code, latitude: destination_hub.latitude, longitude: destination_hub.longitude) }
  let(:cargo_creator) { instance_double(OfferCalculator::Service::CargoCreator, perform: true) }
  let(:params) do
    base_params.merge(
      origin: {
        id: origin_response.id,
        nexus_id: origin_hub.nexus_id
      },
      destination: {
        id: destination_response.id,
        nexus_id: destination_hub.nexus_id
      }
    )
  end

  before do
    FactoryBot.create(:companies_membership, client: user, company: company)
    Organizations.current_id = organization.id
    allow(OfferCalculator::Service::CargoCreator).to receive(:new).and_return(cargo_creator)
    allow(Carta::Client).to receive(:suggest).with(query: "DEHAM").and_return(origin_response)
    allow(Carta::Client).to receive(:suggest).with(query: "CNSGH").and_return(destination_response)
    allow(Carta::Client).to receive(:lookup).with(id: origin_response.id).and_return(origin_response)
    allow(Carta::Client).to receive(:lookup).with(id: destination_response.id).and_return(destination_response)
    allow(Carta::Client).to receive(:reverse_geocode).with(latitude: origin_hub.latitude, longitude: origin_hub.longitude).and_return(origin_response)
    allow(Carta::Client).to receive(:reverse_geocode).with(latitude: destination_hub.latitude, longitude: destination_hub.longitude).and_return(destination_response)
    [origin_hub, destination_hub].each do |hub|
      Geocoder::Lookup::Test.add_stub([hub.latitude, hub.longitude], [
        "address_components" => [{ "types" => ["premise"] }],
        "address" => hub.address.geocoded_address,
        "city" => hub.address.city,
        "country" => hub.nexus.country.name,
        "country_code" => hub.nexus.country.code,
        "postal_code" => hub.address.zip_code
      ])
    end
  end

  describe "#query" do
    let(:query) { service.query }

    context "with Api::V2 style routing params port to door" do
      let(:params) do
        base_params.merge(
          origin: {
            id: origin_response.id,
            nexus_id: origin_hub.nexus_id
          },
          destination: {
            id: destination_response.id,
            latitude: destination_response.latitude,
            longitude: destination_response.longitude
          }
        )
      end

      it "sets the geo_ids on the Query", :aggregate_failures do
        expect(query.origin_geo_id).to eq(origin_response.id)
        expect(query.destination_geo_id).to eq(destination_response.id)
      end
    end

    context "with Dipper style routing params port to door" do
      let(:params) do
        base_params.merge(
          origin: {
            nexus_id: origin_hub.nexus_id
          },
          destination: {
            latitude: destination_response.latitude,
            longitude: destination_response.longitude
          }
        )
      end

      it "sets the geo_ids on the Query", :aggregate_failures do
        expect(query.origin_geo_id).to eq(origin_response.id)
        expect(query.destination_geo_id).to eq(destination_response.id)
      end
    end

    it "sets the address info on the Query", :aggregate_failures do
      expect(query.origin).to eq(origin_hub.nexus.name)
      expect(query.origin_coordinates).to eq(origin_hub.address.point)
      expect(query.destination).to eq(destination_hub.nexus.name)
      expect(query.destination_coordinates).to eq(destination_hub.address.point)
    end

    it "triggers the CargoCreator class when persist is true" do
      service.query
      expect(cargo_creator).to have_received(:perform).once
    end

    it "persists the load type correctly" do
      expect(query.load_type).to eq("fcl")
    end

    context "when 'load_type' is 'cargo_item'" do
      let(:load_type) { "cargo_item" }

      it "persists the load type correctly" do
        expect(query.load_type).to eq("lcl")
      end
    end

    context "when `persist` is false" do
      let(:persist) { false }

      it "ignores the cargo creator class and returns a non-persisted Query", :aggregate_failures do
        expect(service.query).not_to be_persisted
        expect(cargo_creator).not_to have_received(:perform)
      end
    end

    context "when creating cargo fails" do
      before { allow(cargo_creator).to receive(:perform).and_raise(OfferCalculator::Errors::InvalidCargoUnit) }

      it "raise the InvalidCargoUnit error and passes it through" do
        expect { service.query }.to raise_error(OfferCalculator::Errors::InvalidCargoUnit)
      end
    end

    context "when creating Query fails due to invalid Query" do
      let(:source) { instance_double(Doorkeeper::Application, id: nil) }

      it "raise the InvalidQuery error" do
        expect { service.query }.to raise_error(OfferCalculator::Errors::InvalidQuery)
      end
    end
  end
end
