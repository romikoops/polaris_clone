# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pricings::MarginCreator do
  let(:load_type) { "cargo_item" }
  let(:direction) { "export" }
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:vehicle) { FactoryBot.create(:vehicle, tenant_vehicles: [tenant_vehicle_1]) }
  let!(:tenant_vehicles) do
    %w[slowly fast faster].map do |name|
      FactoryBot.create(:legacy_tenant_vehicle, name: name, organization: organization)
    end
  end
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:group_1) { FactoryBot.create(:groups_group, organization: organization) }
  let(:itinerary_1) { FactoryBot.create(:legacy_itinerary, organization: organization) }
  let(:itinerary_ids) { [] }
  let(:tenant_vehicle_ids) { [] }
  let(:cargo_classes) { [] }
  let(:hub_ids) { [] }
  let(:marginType) { "freight" }
  let(:marginValue) { "10" }
  let(:groupId) { group_1.id }
  let(:operand) { {"label": "percentage", "value": "%"} }
  let(:fine_fee_values) { [] }
  let(:attached_to) { "itinerary" }
  let(:directions) { [] }
  let(:args) do
    {
      itinerary_ids: itinerary_ids,
      hub_ids: hub_ids,
      cargo_classes: cargo_classes,
      tenant_vehicle_ids: tenant_vehicle_ids,
      pricing_id: nil,
      selectedHubDirection: nil,
      marginType: marginType,
      organization_id: organization.id,
      groupId: group_1.id,
      directions: directions,
      operand: operand,
      attached_to: attached_to,
      marginValue: marginValue,
      fineFeeValues: fine_fee_values,
      effective_date: "2019-06-21T10:21:24.650Z",
      expiration_date: "2020-06-05T10:00:00.000Z"
    }
  end
  let(:hub) { itinerary_1.stops.first.hub }
  let(:new_margins) { described_class.new(args).perform }

  describe ".perform" do
    context "with freight margin all defaults" do
      it "creates a margin for all itineraries, service levels and cargo classes" do
        aggregate_failures do
          expect(new_margins.length).to eq(1)
          expect(new_margins.first.value).to eq(0.10)
          expect(new_margins.first.operator).to eq("%")
          expect(new_margins.first.applicable_type).to eq("Groups::Group")
          expect(new_margins.first.cargo_class).to eq("All")
        end
      end
    end

    context "with freight margin one itinerary, all defaults" do
      let(:itinerary_ids) { [itinerary_1.id] }

      it "creates a margin for one itinerary, all service levels and cargo classes" do
        aggregate_failures do
          expect(new_margins.length).to eq(1)
          expect(new_margins.first.value).to eq(0.10)
          expect(new_margins.first.operator).to eq("%")
          expect(new_margins.first.applicable_type).to eq("Groups::Group")
          expect(new_margins.first.itinerary_id).to eq(itinerary_1.id)
          expect(new_margins.first.cargo_class).to eq("All")
        end
      end
    end

    context "with freight margin one itinerary, negative percentage margin" do
      let(:itinerary_ids) { [itinerary_1.id] }
      let(:marginType) { "freight" }
      let(:marginValue) { "-10" }
      let(:groupId) { group_1.id }

      it "creates a margin for one itinerary, all service levels and cargo classes" do
        aggregate_failures do
          expect(new_margins.length).to eq(1)
          expect(new_margins.first.value).to eq(-0.10)
          expect(new_margins.first.operator).to eq("%")
        end
      end
    end

    context "with freight margin one itinerary, fee details" do
      let(:itinerary_ids) { [itinerary_1.id] }
      let(:marginValue) { "0" }
      let(:fine_fee_values) {
        {
          "BAS - Basic Ocean Freight": {"operand": {"label": "percentage", "value": "%"}, "value": "10"},
          "HAS - Heavy Weight Surcharge": {"operand": {"label": "addition", "value": "+"}, "value": "10"}
        }
      }

      it "creates a margin for one itinerary, all service levels and cargo classes with fee details" do
        aggregate_failures do
          expect(new_margins.length).to eq(1)
          expect(new_margins.first.details.length).to eq(2)
          expect(new_margins.first.details.count { |d| d.operator == "%" }).to eq(1)
          expect(new_margins.first.details.count { |d| d.operator == "+" }).to eq(1)
        end
      end
    end

    context "with freight margin one hub, all defaults" do
      let(:hub_ids) { [hub.id] }
      let(:directions) { ["export"] }
      let(:attached_to) { "hub" }

      it "creates a margin for one hub, all service levels and cargo classes" do
        aggregate_failures do
          expect(new_margins.length).to eq(1)
          expect(new_margins.first.origin_hub_id).to eq(hub.id)
        end
      end
    end

    context "with freight margin multiple hubs and cargo classes" do
      let(:hub_ids) { itinerary_1.stops.pluck(:hub_id) }
      let(:cargo_classes) { %w[fcl_20 fcl_40 fcl_40_hq] }
      let(:directions) { ["export"] }

      it "creates a margin for multiple hubs, all service levels and multiple cargo classes" do
        aggregate_failures do
          expect(new_margins.length).to eq(6)
          expect(new_margins.map(&:origin_hub_id).uniq).to eq(hub_ids)
          expect(new_margins.map(&:cargo_class).uniq).to eq(%w[fcl_20 fcl_40 fcl_40_hq])
        end
      end
    end

    context "when (trucking) one hub, all cargo classes" do
      let(:marginType) { "trucking" }
      let(:directions) { ["export"] }
      let(:hub_ids) { [hub.id] }

      it "creates a margin for one hub, all cargo classes" do
        aggregate_failures do
          expect(new_margins.length).to eq(1)
          expect(new_margins.first.value).to eq(0.10)
          expect(new_margins.first.operator).to eq("%")
          expect(new_margins.first.applicable_type).to eq("Groups::Group")
          expect(new_margins.first.tenant_vehicle_id).to eq(nil)
          expect(new_margins.first.destination_hub_id).to eq(hub.id)
        end
      end
    end

    context "when (local charge) one hub, all cargo classes" do
      let(:marginType) { "local_charges" }
      let(:directions) { ["export"] }
      let(:hub_ids) { [hub.id] }

      it "creates a margin for one hub, all cargo classes" do
        aggregate_failures do
          expect(new_margins.length).to eq(1)
          expect(new_margins.first.value).to eq(0.10)
          expect(new_margins.first.operator).to eq("%")
          expect(new_margins.first.origin_hub_id).to eq(hub.id)
          expect(new_margins.first.cargo_class).to eq("All")
        end
      end
    end

    context "when (local charge) one hub, all cargo classes with fees" do
      let(:marginType) { "local_charges" }
      let(:directions) { ["export"] }
      let(:hub_ids) { [hub.id] }
      let(:fine_fee_values) do
        {
          "DOC - Documentation": {
            "operand": {"label": "percentage", "value": "%"},
            "value": "10"
          },
          "HDL - Handling Fee": {
            "operand": {"label": "addition", "value": "+"}, "value": "10"
          }
        }
      end

      it "creates a margin for one hub, all cargo classes with fees" do
        aggregate_failures do
          expect(new_margins.length).to eq(1)
          expect(new_margins.first.origin_hub_id).to eq(hub.id)
          expect(new_margins.first.cargo_class).to eq("All")
          expect(new_margins.first.details.length).to eq(2)
          expect(new_margins.first.details.count { |d| d.operator == "%" }).to eq(1)
          expect(new_margins.first.details.count { |d| d.operator == "+" }).to eq(1)
        end
      end
    end
  end

  describe ".create_default_margins" do
    let(:new_tenant) { FactoryBot.create(:organizations_organization) }

    it "creates default margins for new tenants" do
      described_class.create_default_margins(new_tenant)
      expect(::Pricings::Margin.where(organization: new_tenant).count).to eq(35)
    end
  end
end
