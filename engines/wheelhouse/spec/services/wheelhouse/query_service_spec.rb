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
      let(:aggregated) { false }
      let(:origin) {
        FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode)
      }
      let(:destination) {
        FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode)
      }
      let(:siren_params) do
        {
          aggregated: aggregated,
          items: items,
          load_type: load_type,
          origin_id: origin.id,
          destination_id: destination.id,
          organization_id: organization.id
        }
      end
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
        let(:items) do
          [
            {
              stackable: true,
              valid: true,
              dangerous: false,
              cargo_item_type_id: pallet.id,
              quantity: 1,
              length: 120,
              width: 100,
              height: 120,
              weight: 1200,
              commodity_codes: []
            }
          ]
        end
        let(:load_type) { "cargo_item" }

        it "correctly processes the params", :aggregate_failures do
          expect(query_request_params.dig(:cargo_items_attributes)).to be_present
          expect(query_request_params.dig(:origin, :nexus_id)).to eq(origin_hub.nexus_id)
          expect(query_request_params.dig(:destination, :nexus_id)).to eq(destination_hub.nexus_id)
        end
      end

      context "when fcl_20" do
        let(:items) do
          [
            {
              valid: true,
              dangerous: false,
              equipment_id: "ee9b339d-6aee-466a-b8d4-b1c08a4731d4",
              quantity: 1,
              weight: 1200,
              commodity_codes: []
            }
          ]
        end
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
