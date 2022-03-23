# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Recalculate do
  let(:query) do
    FactoryBot.create(:journey_query,
      client: client,
      source_id: application.id,
      organization: organization,
      cargo_count: 0,
      cargo_units: [cargo_unit],
      status: "failed")
  end
  let(:cargo_unit) { FactoryBot.build(:journey_cargo_unit, commodity_infos: [commodity_info]) }
  let(:commodity_info) { FactoryBot.build(:journey_commodity_info) }
  let(:new_query) { described_class.new(original_query: query).perform }
  let(:application) { FactoryBot.create(:application) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:client) { FactoryBot.create(:users_client, organization: organization) }

  before do
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    shared_examples_for "duplicating cargo units" do
      let(:new_cargo_unit) { new_query.cargo_units.first }
      let(:new_commodity_info) { new_cargo_unit.commodity_infos.first }

      it "duplicates the Query's cargo units", :aggregate_failures do
        expect(new_cargo_unit.weight).to eq(cargo_unit.weight)
        expect(new_cargo_unit.height).to eq(cargo_unit.height)
        expect(new_cargo_unit.length).to eq(cargo_unit.length)
        expect(new_cargo_unit.width).to eq(cargo_unit.width)
        expect(new_cargo_unit.cargo_class).to eq(cargo_unit.cargo_class)
      end

      it "duplicates the CommodityInfo's", :aggregate_failures do
        expect(new_commodity_info.hs_code).to eq(commodity_info.hs_code)
        expect(new_commodity_info.imo_class).to eq(commodity_info.imo_class)
        expect(new_commodity_info.description).to eq(commodity_info.description)
      end
    end

    it "duplicates the Query", :aggregate_failures do
      expect(new_query.client_id).to eq(query.client_id)
      expect(new_query.organization_id).to eq(query.organization_id)
      expect(new_query.load_type).to eq(query.load_type)
      expect(new_query.currency).to eq(organization.scope.default_currency)
      expect(new_query.status).to eq("running")
    end

    context "when cargo units are FCL" do
      let(:cargo_unit) { FactoryBot.build(:journey_cargo_unit, :fcl, commodity_infos: [commodity_info]) }

      it_behaves_like "duplicating cargo units"
    end

    context "when cargo units are LCL" do
      let(:cargo_unit) { FactoryBot.build(:journey_cargo_unit, commodity_infos: [commodity_info]) }

      it_behaves_like "duplicating cargo units"
    end

    context "when cargo units are Aggregated LCL" do
      let(:cargo_unit) { FactoryBot.build(:journey_cargo_unit, :aggregate_lcl, commodity_infos: [commodity_info]) }

      it_behaves_like "duplicating cargo units"
    end

    context "when the Client has updated their desired currency" do
      let(:client) do
        FactoryBot.create(:users_client,
          organization: organization,
          settings: FactoryBot.build(:users_client_settings, currency: "ZAR"))
      end

      it "updates the currency on the new Query" do
        expect(new_query.currency).to eq("ZAR")
      end
    end
  end
end
