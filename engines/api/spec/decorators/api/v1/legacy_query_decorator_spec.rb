# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::LegacyQueryDecorator do
  include_context "journey_complete_request"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:scope) { Organizations::DEFAULT_SCOPE.deep_dup.with_indifferent_access }
  let(:decorated_query) { described_class.new(query, context: { scope: scope }) }
  let(:legacy_format) { decorated_query.legacy_json }
  let(:line_item) { result.line_item_sets.first.line_items.first }
  let(:line_items) do
    freight_line_items_with_cargo
  end
  let(:route_sections) do
    [freight_section]
  end

  before do
    %w[
      cargo
    ].each do |code|
      FactoryBot.create(:legacy_charge_categories, code: code, name: code.humanize, organization: organization)
    end
    FactoryBot.create(:treasury_exchange_rate, from: "EUR", to: "USD")
    breakdown
  end

  describe "#legacy_json" do
    it "returns the legacy response format", :aggregate_failures do
      expect(legacy_format[:quotationId]).to eq(query.id)
      expect(legacy_format[:completed]).to be_present
    end

    context "when aggregate cargo units" do
      let(:cargo_units) { [FactoryBot.build(:journey_cargo_unit, :aggregate_lcl)] }

      it "returns the empty cargo units and has data in aggregatedCargo", :aggregate_failures do
        expect(legacy_format[:cargoUnits]).to be_empty
        expect(legacy_format[:aggregatedCargo]).to eq({
          id: query.cargo_units.first.id, volume: 1.3, weight: 3000
        })
      end
    end
  end
end
