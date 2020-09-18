# frozen_string_literal: true

require "rails_helper"

module ResultFormatter
  RSpec.describe FeeTableService, type: :service do
    let!(:organization) { FactoryBot.create(:organizations_organization) }
    let(:custom_scope) { {primary_freight_code: "BAS", fee_detail: "name"} }
    let(:scope) { Organizations::DEFAULT_SCOPE.deep_dup.merge(custom_scope).with_indifferent_access }
    let(:load_type) { "container" }
    let(:shipment) {
      FactoryBot.create(:legacy_shipment,
        with_full_breakdown: true,
        with_tenders: true,
        load_type: load_type,
        organization: organization)
    }
    let(:type) { :table }
    let(:tender) { shipment.charge_breakdowns.first.tender }
    let(:line_item) { tender.line_items.find { |li| li.code == "bas" } }
    let(:klass) { described_class.new(tender: tender, scope: scope, type: type) }

    describe ".perform" do
      let(:expected_descriptions) do
        [nil,
          "Trucking pre",
          "1 x Fcl 20",
          "Trucking Rate",
          "Export",
          "1 x Fcl 20",
          "Terminal Handling Cost",
          "Cargo",
          "1 x Fcl 20",
          "Basic Ocean Freight",
          "Import",
          "1 x Fcl 20",
          "Terminal Handling Cost",
          "Trucking on",
          "1 x Fcl 20",
          "Trucking Rate"]
      end

      before do
        Legacy::ExchangeRate.create(from: "EUR", to: "USD", rate: 1.3, created_at: 30.seconds.ago)
      end

      context "with container load type" do
        it "returns rows for each level of charge table" do
          results = klass.perform
          aggregate_failures do
            expect(results.length).to eq(16)
            expect(results.pluck(:description)).to eq(expected_descriptions)
            expect(results.pluck(:lineItemId).compact).to match_array(tender.line_items.ids)
          end
        end
      end

      context "with cargo_item load type" do
        let(:load_type) { "cargo_item" }
        let(:expected_descriptions) do
          [nil,
            "Trucking pre",
            "1 x Pallet",
            "Trucking Rate",
            "Export",
            "1 x Pallet",
            "Terminal Handling Cost",
            "Cargo",
            "1 x Pallet",
            "Basic Ocean Freight",
            "Import",
            "1 x Pallet",
            "Terminal Handling Cost",
            "Trucking on",
            "1 x Pallet",
            "Trucking Rate"]
        end

        it "returns rows for each level of charge table" do
          results = klass.perform
          aggregate_failures do
            expect(results.length).to eq(16)
            expect(results.pluck(:description)).to eq(expected_descriptions)
            expect(results.pluck(:lineItemId).compact).to match_array(tender.line_items.ids)
          end
        end
      end

      context "with varied currencies" do
        let(:load_type) { "cargo_item" }
        let(:expected_descriptions) do
          [nil,
            "Trucking pre",
            "1 x Pallet",
            "Trucking Rate",
            "Export",
            "1 x Pallet",
            "Terminal Handling Cost",
            "Shipment",
            "Fees charged in USD:",
            "SOLAS FEE",
            "Cargo",
            "1 x Pallet",
            "Basic Ocean Freight",
            "Import",
            "1 x Pallet",
            "Terminal Handling Cost",
            "Trucking on",
            "1 x Pallet",
            "Trucking Rate"]
        end

        before do
          FactoryBot.create(:quotations_line_item,
            tender: tender,
            section: :export_section,
            amount: Money.new(3500, "USD"),
            original_amount: Money.new(3500, "USD"),
            charge_category: FactoryBot.create(:solas_charge))
        end

        it "returns rows for each level of charge table" do
          results = klass.perform
          aggregate_failures do
            expect(results.length).to eq(19)
            expect(results.pluck(:description)).to eq(expected_descriptions)
            expect(results.pluck(:lineItemId).compact).to match_array(tender.line_items.ids)
          end
        end
      end

      context "with custom names" do
        before do
          FactoryBot.create(:legacy_charge_categories, code: "cargo", name: "Bananas", organization: organization)
        end

        let(:load_type) { "cargo_item" }
        let(:expected_descriptions) do
          [nil,
            "Trucking pre",
            "1 x Pallet",
            "Trucking Rate",
            "Export",
            "1 x Pallet",
            "Terminal Handling Cost",
            "Bananas",
            "1 x Pallet",
            "Basic Ocean Freight",
            "Import",
            "1 x Pallet",
            "Terminal Handling Cost",
            "Trucking on",
            "1 x Pallet",
            "Trucking Rate"]
        end

        it "returns rows for each level of charge table" do
          results = klass.perform
          aggregate_failures do
            expect(results.length).to eq(16)
            expect(results.pluck(:description)).to eq(expected_descriptions)
            expect(results.pluck(:lineItemId).compact).to match_array(tender.line_items.ids)
          end
        end
      end

      context "with cargo_item load type" do
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

      context "with cargo consolidation" do
        let(:custom_scope) { {consolidation: {cargo: {backend: true}}, fee_detail: "name"} }
        let(:load_type) { "cargo_item" }
        let(:results) { klass.perform }
        let(:expected_descriptions) do
          [nil,
            "Trucking pre",
            "Trucking Rate",
            "Export",
            "Terminal Handling Cost",
            "Cargo",
            "Basic Ocean Freight",
            "Import",
            "Terminal Handling Cost",
            "Trucking on",
            "Trucking Rate"]
        end

        it "returns rows for each level of charge table" do
          aggregate_failures do
            expect(results.length).to eq(11)
            expect(results.pluck(:description)).to eq(expected_descriptions)
            expect(results.pluck(:lineItemId).compact).to match_array(tender.line_items.ids)
          end
        end
      end

      context "with multiple currencies" do
        let!(:second_line_item) {
          FactoryBot.create(:quotations_line_item,
            charge_category: FactoryBot.create(:baf_charge),
            section: "export_section",
            tender: tender,
            amount: Money.new(1000, "SEK"))
        }
        let(:load_type) { "cargo_item" }
        let(:results) { klass.perform }
        let(:expected_descriptions) do
          [nil,
            "Trucking pre",
            "1 x Pallet",
            "Trucking Rate",
            "Export",
            "1 x Pallet",
            "Terminal Handling Cost",
            "Shipment",
            "Fees charged in SEK:",
            "Bunker Adjustment Fee",
            "Cargo",
            "1 x Pallet",
            "Basic Ocean Freight",
            "Import",
            "1 x Pallet",
            "Terminal Handling Cost",
            "Trucking on",
            "1 x Pallet",
            "Trucking Rate"]
        end

        before do
          Legacy::ExchangeRate.create(from: "USD",
                                      to: "SEK", rate: 1.2,
                                      created_at: tender.created_at - 30.seconds)
        end

        it "returns rows for each level of charge table" do
          aggregate_failures do
            expect(results.length).to eq(19)
            expect(results.pluck(:description)).to eq(expected_descriptions)
            expect(results.pluck(:lineItemId).compact).to match_array(tender.line_items.ids)
          end
        end
      end

      context "when there are multiple exchange rates" do
        let(:quotation) { FactoryBot.create(:quotations_quotation, organization: organization) }
        let(:tender) { FactoryBot.create(:quotations_tender, quotation: quotation, created_at: Time.zone.now - 1.day) }
        let(:usd_sek_rate) { 1.3 }
        let(:valid_exchange_rate) { {rate: usd_sek_rate, created_at: tender.created_at - 1.day} }
        let(:rates) { [valid_exchange_rate, {rate: 3.04, created_at: tender.created_at + 2.days}] }

        before do
          FactoryBot.create(:quotations_line_item,
            tender: tender,
            section: :export_section,
            amount: Money.new(3500, "SEK"),
            charge_category: FactoryBot.create(:solas_charge, organization: organization, code: :export))

          rates.each do |rate|
            Legacy::ExchangeRate.create(from: tender.amount.currency.iso_code,
                                        to: "SEK", rate: rate[:rate],
                                        created_at: rate[:created_at])
          end
        end

        it "uses the rate valid at time of tender creation for currency conversion" do
          results = described_class.new(tender: tender, scope: scope, type: type).perform
          rates = ResultFormatter::ExchangeRateService.new(tender: tender).perform
          aggregate_failures do
            expect(results.length).to eq(5)
            expect(rates.dig("sek")).to eq(usd_sek_rate)
          end
        end
      end

      context "with custom order" do
        let(:custom_scope) do
          {
            quote_card: {
              order: %w[
                trucking_on
                cargo
                import
                export
                trucking_pre
              ],
              sections: {
                trucking_on: true,
                cargo: true,
                import: true,
                export: true,
                trucking_pre: true
              }
            },
            fee_detail: "name"
          }
        end
        let(:load_type) { "cargo_item" }
        let(:results) { klass.perform }
        let(:expected_descriptions) do
          [
            nil,
            "Trucking on",
            "1 x Pallet",
            "Trucking Rate",
            "Cargo",
            "1 x Pallet",
            "Basic Ocean Freight",
            "Import",
            "1 x Pallet",
            "Terminal Handling Cost",
            "Export",
            "1 x Pallet",
            "Terminal Handling Cost",
            "Trucking pre",
            "1 x Pallet",
            "Trucking Rate"
          ]
        end

        it "returns rows for each level of charge table" do
          aggregate_failures do
            expect(results.length).to eq(16)
            expect(results.pluck(:description)).to eq(expected_descriptions)
            expect(results.pluck(:lineItemId).compact).to match_array(tender.line_items.ids)
          end
        end
      end

      context "with collapsed sections" do
        let(:custom_scope) do
          {
            quote_card: {
              order: %w[
                trucking_on
                cargo
                import
                export
                trucking_pre
              ],
              sections: {
                trucking_on: false,
                cargo: true,
                import: true,
                export: true,
                trucking_pre: false
              }
            },
            fee_detail: "name"
          }
        end
        let(:load_type) { "cargo_item" }
        let(:results) { klass.perform }
        let(:expected_descriptions) do
          [
            nil,
            "Trucking on",
            "Cargo",
            "1 x Pallet",
            "Basic Ocean Freight",
            "Import",
            "1 x Pallet",
            "Terminal Handling Cost",
            "Export",
            "1 x Pallet",
            "Terminal Handling Cost",
            "Trucking pre"
          ]
        end

        it "returns rows for each level of charge table" do
          aggregate_failures do
            expect(results.length).to eq(12)
            expect(results.pluck(:description)).to eq(expected_descriptions)
          end
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

      context "with finer values (pdf)" do
        let(:type) { :pdf }
        let(:amount) { 123.456789 }

        it "returns the raw value" do
          expect(result[:amount]).to eq("1.23")
        end
      end
    end
  end
end
