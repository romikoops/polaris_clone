# frozen_string_literal: true

require "rails_helper"

module ResultFormatter
  RSpec.describe FeeTableService, type: :service do
    let!(:organization) { FactoryBot.create(:organizations_organization) }
    let(:scope) { {primary_freight_code: "BAS"} }
    let(:shipment) {
      FactoryBot.create(:legacy_shipment,
        with_full_breakdown: true,
        with_tenders: true,
        organization: organization)
    }
    let(:type) { :table }
    let(:tender) { shipment.charge_breakdowns.first.tender }
    let(:line_item) { tender.line_items.find { |li| li.code == "bas" } }
    let(:klass) { described_class.new(tender: tender, scope: scope, type: type) }

    describe ".perform" do
      let(:expected_descriptions) do
        ["Pre-Carriage",
          "1 x Fcl 20",
          "Fees charged in EUR:",
          "Trucking Rate",
          "Export Local Charges",
          "1 x Fcl 20",
          "Fees charged in EUR:",
          "Basic Freight",
          "Freight Charges",
          "1 x Fcl 20",
          "Fees charged in EUR:",
          "Ocean Freight Rate",
          "Import Local Charges",
          "1 x Fcl 20",
          "Fees charged in EUR:",
          "Basic Freight",
          "On-Carriage",
          "1 x Fcl 20",
          "Fees charged in EUR:",
          "Trucking Rate",
          nil]
      end

      context "with container load type" do
        it "returns rows for each level of charge table" do
          results = klass.perform
          aggregate_failures do
            expect(results.length).to eq(21)
            expect(results.pluck(:description)).to match_array(expected_descriptions)
            expect(results.pluck(:lineItemId).compact).to match_array(tender.line_items.ids)
          end
        end
      end

      context "with cargo_item load type" do
        let(:shipment) {
          FactoryBot.create(:legacy_shipment,
            load_type: "cargo_item",
            with_full_breakdown: true,
            with_tenders: true,
            organization: organization)
        }
        let(:expected_descriptions) do
          ["Pre-Carriage",
            "1 x Pallet",
            "Fees charged in EUR:",
            "Trucking Rate",
            "Export Local Charges",
            "1 x Pallet",
            "Fees charged in EUR:",
            "Basic Freight",
            "Freight Charges",
            "1 x Pallet",
            "Fees charged in EUR:",
            "Ocean Freight Rate",
            "Import Local Charges",
            "1 x Pallet",
            "Fees charged in EUR:",
            "Basic Freight",
            "On-Carriage",
            "1 x Pallet",
            "Fees charged in EUR:",
            "Trucking Rate",
            nil]
        end

        it "returns rows for each level of charge table" do
          results = klass.perform
          aggregate_failures do
            expect(results.length).to eq(21)
            expect(results.pluck(:description)).to match_array(expected_descriptions)
            expect(results.pluck(:lineItemId).compact).to match_array(tender.line_items.ids)
          end
        end
      end

      context "with cargo_item load type" do
        let(:scope) { {primary_freight_code: "BAS"} }
        let!(:second_line_item) {
          FactoryBot.create(:quotations_line_item,
            charge_category: FactoryBot.create(:baf_charge),
            section: "cargo_section",
            tender: tender)
        }
        let(:results) { klass.perform }
        let(:main_fee_item_index) { results.index(results.find { |r| r[:lineItemId] == line_item.id }) }
        let(:second_fee_item_index) { results.index(results.find { |r| r[:lineItemId] == second_line_item.id }) }

        it "returns rows for each level of charge table" do
          expect(main_fee_item_index < second_fee_item_index).to be_truthy
        end
      end
    end

    describe ".value_with_currency" do
      let(:amount) { 10000 }
      let(:currency) { "USD" }
      let(:money) { Money.new(amount, currency) }
      let(:result) { klass.send(:value_with_currency, money) }

      context "with complete dollar value" do
        let(:type) { :pdf }

        it "returns the value with suffix .00" do
          expect(result[:amount]).to eq("100.00")
        end
      end

      context "with raw value" do
        it "returns the raw value" do
          expect(result[:amount]).to eq(100.0)
        end
      end
    end
  end
end
