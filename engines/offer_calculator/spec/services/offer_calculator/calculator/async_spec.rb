# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Calculator do
  let(:cargo_classes) { %w[fcl_20 fcl_40 fcl_40_hq] }
  let(:load_type) { "container" }
  let(:source) { FactoryBot.create(:application) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:container_attributes) do
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
  let(:params) do
    {
      async: true,
      direction: "export",
      selected_day: 4.days.from_now.beginning_of_day.to_s,
      cargo_items_attributes: [],
      containers_attributes: container_attributes,
      trucking: {
        pre_carriage: {
          address_id: pickup_address.id,
          truck_type: "chassis"
        },
        on_carriage: {
          address_id: delivery_address.id,
          truck_type: "chassis"
        }
      },
      origin: {
        nexus_id: origin_hub.nexus_id,
        nexus_name: origin_hub.nexus.name,
        country: origin_hub.nexus.country.code,
        full_address: pickup_address.geocoded_address
      },
      destination: {
        nexus_id: destination_hub.nexus_id,
        nexus_name: destination_hub.nexus.name,
        country: destination_hub.nexus.country.code,
        full_address: delivery_address.geocoded_address
      },
      incoterm: {},
      aggregated_cargo_attributes: nil
    }
  end
  let(:quotation) { service.quotation }
  let(:wheelhouse) { false }
  let(:service) do
    described_class.new(
      params: params,
      client: user,
      creator: user,
      source: source
    )
  end

  include_context "complete_route_with_trucking"

  before do
    FactoryBot.create(:companies_membership, client: user)
    Organizations.current_id = organization.id
    allow(service).to receive(:async_calculation_for_permutation)
  end

  describe ".perform" do
    let!(:result) { service.perform }

    context "with single trucking Availability" do
      it "queues one job for each permutation and returns the quotation", :aggregate_failures do
        expect(service).to have_received(:async_calculation_for_permutation).with(pre_carriage: true, on_carriage: true)
        expect(service).to have_received(:async_calculation_for_permutation).with(pre_carriage: true, on_carriage: false)
        expect(service).to have_received(:async_calculation_for_permutation).with(pre_carriage: false, on_carriage: true)
        expect(service).to have_received(:async_calculation_for_permutation).with(pre_carriage: false, on_carriage: false)
        expect(result).to be_a(Journey::Query)
      end
    end
  end
end
