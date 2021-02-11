# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::LegacyQuote do
  include_context "journey_complete_request"
  let(:organization) { FactoryBot.create(:organizations_organization) }

  let(:client) { FactoryBot.create(:users_client) }
  let(:scope) { {} }
  let(:quote_service) do
    described_class.new(
      result: result,
      scope: scope
    )
  end
  let(:quote) do
    quote_service.perform
  end

  let(:line_items) do
    freight_line_items_with_cargo
  end
  before do
    %w[cargo import export trucking_pre trucking_on].each do |code|
      FactoryBot.create(:legacy_charge_categories,
        organization: organization,
        code: code,
        name: code.humanize)
    end
  end

  context "when it returns a complete quote" do
    it "returns a complete quote with rate data" do
      expect(quote).to match_response_schema("legacy/simple_quote")
    end
  end

  context "with custom charge_categories" do
    before do
      Legacy::ChargeCategory.find_by(
        organization: organization,
        code: "cargo"
      ).update(name: "Banana")
    end

    it "returns a complete quote with rate data and correct labels" do
      expect(quote.dig("cargo", "name")).to eq("Banana")
    end
  end

  context "when it hides the grand total" do
    let(:scope) { {hide_grand_total: true} }
    let(:quote) { described_class.quote(result: result, scope: scope) }

    it "returns a complete quote with hidden grand total" do
      expect(quote).to match_response_schema("legacy/hidden_grand_total_quote")
    end
  end

  context "when it hides the grand total when multiple currencies are there" do
    let(:scope) { {hide_converted_grand_total: true} }

    before do
      FactoryBot.create(:journey_line_item,
        line_item_set: line_item_set,
        route_section: freight_section,
        total_currency: "SEK")
    end

    it "returns a complete quote with hidden grand total" do
      expect(quote).to match_response_schema("legacy/hidden_grand_total_quote")
    end
  end

  context "when it hides the sub total" do
    let(:scope) { {hide_sub_totals: true} }

    it "returns a complete quote with hidden grand total" do
      expect(quote).to match_response_schema("legacy/hidden_sub_totals_quote")
    end
  end

  context "when the client is missing" do
    before do
      allow(quote_service).to receive(:query).and_return(query)
    end
    let(:query) { FactoryBot.build(:journey_query, client: nil, organization: organization) }

    it "returns a complete quote with all totals hidden" do
      expect(quote).to match_response_schema("legacy/guest_quote")
    end
  end

  context "when a full booking with cargo and shipment fees" do
    let(:line_items) do
      [
        pre_carriage_line_items_with_cargo,
        pre_carriage_line_item_per_shipment,
        origin_transfer_line_items_with_cargo,
        origin_transfer_line_item_per_shipment,
        freight_line_items_with_cargo,
        freight_line_item_per_shipment,
        destination_transfer_line_items_with_cargo,
        destination_transfer_line_item_per_shipment,
        on_carriage_line_items_with_cargo,
        on_carriage_line_item_per_shipment
      ].flatten
    end

    it "returns a complete quote with all sections filled properly" do
      expect(quote).to match_response_schema("legacy/full_quote")
    end
  end

  context "when a full booking with cargo and shipment fees" do
    let(:scope) { {consolidation: {backend: {cargo: true}}} }

    let(:line_items) do
      [
        pre_carriage_line_items_with_cargo,
        pre_carriage_line_item_per_shipment,
        origin_transfer_line_items_with_cargo,
        origin_transfer_line_item_per_shipment,
        freight_line_items_with_cargo,
        freight_line_item_per_shipment,
        destination_transfer_line_items_with_cargo,
        destination_transfer_line_item_per_shipment,
        on_carriage_line_items_with_cargo,
        on_carriage_line_item_per_shipment
      ].flatten
    end

    it "returns a complete quote with all sections filled properly" do
      expect(quote).to match_response_schema("legacy/consolidated_quote")
    end
  end
end
