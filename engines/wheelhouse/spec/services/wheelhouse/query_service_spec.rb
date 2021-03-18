# frozen_string_literal: true

require "rails_helper"

module Wheelhouse
  RSpec.describe QueryService, type: :service do
    ActiveJob::Base.queue_adapter = :test

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:source) { FactoryBot.create(:application, name: "siren") }
    let(:query_service) {
      described_class.new(
        creator: user,
        client: user,
        source: source,
        params: siren_params
      )
    }

    describe "#query_request_params" do
      let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
      let(:origin_hub) { itinerary.origin_hub }
      let(:destination_hub) { itinerary.destination_hub }
      let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
      let(:items) { [] }
      let(:load_type) { "container" }
      let(:origin) {
        FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode)
      }
      let(:destination) {
        FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode)
      }
      let(:siren_params) do
        {
          items: items,
          load_type: load_type,
          origin_id: origin.id,
          destination_id: destination.id,
          organization_id: organization.id
        }
      end
      let(:items) { [item] }
      let(:query_request_params) { query_service.send(:query_request_params) }

      before do
        Organizations.current_id = organization.id
        allow(Carta::Client).to receive(:lookup).with(id: origin.id).and_return(origin)
        allow(Carta::Client).to receive(:lookup).with(id: destination.id).and_return(destination)
        allow(Carta::Client).to receive(:suggest).with(query: origin_hub.nexus.locode).and_return(origin_hub.nexus)
        allow(Carta::Client).to receive(:suggest).with(query: destination_hub.nexus.locode).and_return(
          destination_hub.nexus
        )
      end

      context "when lcl" do
        let(:item) {
          {
              stackable: true,
              cargo_class: 'lcl',
              colli_type: 'pallet',
              quantity: 1,
              length: 120,
              width: 100,
              height: 120,
              weight: 1200,
              commodities: []
            }
          }
        let(:load_type) { "cargo_item" }

        it "correctly processes the params", :aggregate_failures do
          expect(query_request_params.dig(:cargo_items_attributes)).to be_present
          expect(query_request_params.dig(:origin, :nexus_id)).to eq(origin_hub.nexus_id)
          expect(query_request_params.dig(:destination, :nexus_id)).to eq(destination_hub.nexus_id)
        end
      end

      context "when Aggregated Cargo Item" do
        let(:item) {
          {
            stackable: true,
            cargo_class: 'aggregated_lcl',
            colli_type: nil,
            quantity: 1,
            length: nil,
            width: nil,
            height: nil,
            weight: 1200,
            volume: 1.1,
            commodities: []
          }
        }

        let(:expected_values) { {weight: item[:weight], volume: item[:volume], commodities: item[:commodities], stackable: true} }
        let(:load_type) { "cargo_item" }

        it "correctly processes the params", :aggregate_failures do
          expect(query_request_params.dig(:aggregated_cargo_attributes)).to match(expected_values)
          expect(query_request_params.dig(:origin, :nexus_id)).to eq(origin_hub.nexus_id)
          expect(query_request_params.dig(:destination, :nexus_id)).to eq(destination_hub.nexus_id)
        end
      end

      context "when fcl_20" do
        let(:item) {
          {
              cargo_class: "fcl_20",
              quantity: 1,
              weight: 1200,
              commodities: []
            }
          }
        let(:load_type) { "container" }

        it "correctly handles fcl param and sets the cargo class" do
          expect(query_request_params.dig(:containers_attributes).pluck(:cargo_class)).to eq(["fcl_20"])
          expect(query_request_params.dig(:origin, :nexus_id)).to eq(origin_hub.nexus_id)
          expect(query_request_params.dig(:destination, :nexus_id)).to eq(destination_hub.nexus_id)
        end
      end
    end
  end
end
