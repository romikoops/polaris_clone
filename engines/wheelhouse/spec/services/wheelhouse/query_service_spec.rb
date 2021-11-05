# frozen_string_literal: true

require "rails_helper"

module Wheelhouse
  RSpec.describe QueryService, type: :service do
    ActiveJob::Base.queue_adapter = :test

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:source) { FactoryBot.create(:application, name: "siren") }
    let(:query_service) do
      described_class.new(
        creator: user,
        client: user,
        source: source,
        params: siren_params
      )
    end

    describe "#query_request_params" do
      let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
      let(:load_type) { "cargo_item" }
      let(:cargo_ready_date) { Time.zone.tomorrow.to_date }
      let(:siren_params) do
        {
          items: [item],
          load_type: load_type,
          origin_id: "xxx1",
          destination_id: "xxx2",
          organization_id: organization.id,
          cargo_ready_date: cargo_ready_date
        }
      end
      let(:query_request_params) { query_service.send(:query_request_params) }
      let(:item) do
        {
          stackable: true,
          cargo_class: "lcl",
          colli_type: "pallet",
          quantity: 1,
          length: 120,
          width: 100,
          height: 120,
          weight: 1200,
          commodities: []
        }
      end

      before do
        FactoryBot.create(:legacy_cargo_item_type)
        Organizations.current_id = organization.id
        allow(Carta::Client).to receive(:lookup).with(id: "xxx1").and_return(
          FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: itinerary.origin_hub.nexus.locode)
        )
        allow(Carta::Client).to receive(:lookup).with(id: "xxx2").and_return(
          FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: itinerary.destination_hub.nexus.locode)
        )
        allow(Carta::Client).to receive(:suggest).with(query: itinerary.origin_hub.nexus.locode).and_return(itinerary.origin_hub.nexus)
        allow(Carta::Client).to receive(:suggest).with(query: itinerary.destination_hub.nexus.locode).and_return(
          itinerary.destination_hub.nexus
        )
      end

      context "when lcl" do
        it "correctly processes the params", :aggregate_failures do
          expect(query_request_params[:cargo_items_attributes]).to be_present
          expect(query_request_params[:selected_day]).to eq(cargo_ready_date)
          expect(query_request_params.dig(:origin, :nexus_id)).to eq(itinerary.origin_hub.nexus_id)
          expect(query_request_params.dig(:destination, :nexus_id)).to eq(itinerary.destination_hub.nexus_id)
        end
      end

      context "when cargo_ready_date is not provided" do
        let(:cargo_ready_date) { nil }

        it "uses todays date as the fallback" do
          expect(query_request_params[:selected_day]).to eq(Time.zone.today.to_s)
        end
      end

      context "when Aggregated Cargo Item" do
        let(:item) do
          {
            stackable: true,
            cargo_class: "aggregated_lcl",
            colli_type: nil,
            quantity: 1,
            length: nil,
            width: nil,
            height: nil,
            weight: 1200,
            volume: 1.1,
            commodities: []
          }
        end

        it "correctly processes the params", :aggregate_failures do
          expect(query_request_params[:aggregated_cargo_attributes]).to match(
            { weight: item[:weight], volume: item[:volume], commodities: item[:commodities], stackable: true }
          )
          expect(query_request_params.dig(:origin, :nexus_id)).to eq(itinerary.origin_hub.nexus_id)
          expect(query_request_params.dig(:destination, :nexus_id)).to eq(itinerary.destination_hub.nexus_id)
        end
      end

      context "when fcl_20" do
        let(:item) do
          {
            cargo_class: "fcl_20",
            quantity: 1,
            weight: 1200,
            commodities: []
          }
        end
        let(:load_type) { "container" }

        it "correctly handles fcl param and sets the cargo class", :aggregate_failures do
          expect(query_request_params[:containers_attributes].pluck(:cargo_class)).to eq(["fcl_20"])
          expect(query_request_params.dig(:origin, :nexus_id)).to eq(itinerary.origin_hub.nexus_id)
          expect(query_request_params.dig(:destination, :nexus_id)).to eq(itinerary.destination_hub.nexus_id)
        end
      end
    end
  end
end
