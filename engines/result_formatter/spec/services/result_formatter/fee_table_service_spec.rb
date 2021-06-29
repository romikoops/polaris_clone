# frozen_string_literal: true

require "rails_helper"
RSpec.shared_examples "FeeTableService results" do
  it "returns rows for each level of charge table", :aggregate_failures do
    expect(results.pluck(:description)).to eq(expected_descriptions)
    expect(results.pluck(:lineItemId).compact).to match_array(line_item_set.line_items.ids)
  end
end

module ResultFormatter
  RSpec.describe FeeTableService, type: :service do
    include_context "journey_pdf_setup"
    let(:currency) { "USD" }
    let!(:organization) { FactoryBot.create(:organizations_organization) }
    let(:custom_scope) { { primary_freight_code: "BAF", fee_detail: "name", default_currency: "USD" } }
    let(:scope) { Organizations::DEFAULT_SCOPE.deep_dup.merge(custom_scope).with_indifferent_access }
    let(:type) { :table }
    let(:cargo_unit_params) do
      [
        {
          cargo_class: cargo_class,
          height_value: 1,
          length_value: 1,
          quantity: 1,
          stackable: true,
          weight_value: 1000,
          width_value: 1
        }
      ]
    end
    let(:cargo_class) { "fcl_20" }
    let(:decorated_result) { ResultFormatter::ResultDecorator.new(result, context: { scope: scope }) }
    let(:klass) { described_class.new(result: decorated_result, scope: scope, type: type) }
    let(:results) { klass.perform }

    describe ".perform" do
      let(:expected_descriptions) do
        [nil,
          "Trucking pre",
          "1 x FCL 20",
          pre_carriage_line_items_with_cargo.first.description,
          "Export",
          "1 x FCL 20",
          origin_transfer_line_items_with_cargo.first.description,
          "Cargo",
          "1 x FCL 20",
          freight_line_items_with_cargo.first.description,
          "Import",
          "1 x FCL 20",
          destination_transfer_line_items_with_cargo.first.description,
          "Trucking on",
          "1 x FCL 20",
          on_carriage_line_items_with_cargo.first.description]
      end

      before do
        Treasury::ExchangeRate.create(from: "EUR", to: "USD", rate: 1.3, created_at: 30.seconds.ago)
      end

      context "with container load type" do
        include_examples "FeeTableService results"
      end

      context "with cargo_item load type" do
        let(:cargo_class) { "lcl" }
        let(:expected_descriptions) do
          [nil,
            "Trucking pre",
            "1 x Pallet",
            pre_carriage_line_items_with_cargo.first.description,
            "Export",
            "1 x Pallet",
            origin_transfer_line_items_with_cargo.first.description,
            "Cargo",
            "1 x Pallet",
            freight_line_items_with_cargo.first.description,
            "Import",
            "1 x Pallet",
            destination_transfer_line_items_with_cargo.first.description,
            "Trucking on",
            "1 x Pallet",
            on_carriage_line_items_with_cargo.first.description]
        end

        include_examples "FeeTableService results"
      end

      context "with varied currencies" do
        let(:cargo_class) { "lcl" }
        let(:expected_descriptions) do
          [nil,
            "Trucking pre",
            "1 x Pallet",
            pre_carriage_line_items_with_cargo.first.description,
            "Export",
            "1 x Pallet",
            origin_transfer_line_items_with_cargo.first.description,
            "Shipment",
            "Fees charged in EUR:",
            solas_line_item.description,
            "Cargo",
            "1 x Pallet",
            freight_line_items_with_cargo.first.description,
            "Import",
            "1 x Pallet",
            destination_transfer_line_items_with_cargo.first.description,
            "Trucking on",
            "1 x Pallet",
            on_carriage_line_items_with_cargo.first.description]
        end
        let(:solas_line_item) do
          FactoryBot.build(:journey_line_item,
            route_section: origin_transfer_section,
            total: Money.new(3500, "EUR"),
            fee_code: "SOLAS",
            description: "SOLAS FEE")
        end

        before do
          line_item_set.line_items << solas_line_item
        end

        include_examples "FeeTableService results"
      end

      context "with custom names" do
        before do
          Legacy::ChargeCategory.find_by(code: "cargo", organization: organization).update(name: "Bananas")
        end

        let(:cargo_class) { "lcl" }
        let(:expected_descriptions) do
          [nil,
            "Trucking pre",
            "1 x Pallet",
            pre_carriage_line_items_with_cargo.first.description,
            "Export",
            "1 x Pallet",
            origin_transfer_line_items_with_cargo.first.description,
            "Bananas",
            "1 x Pallet",
            freight_line_items_with_cargo.first.description,
            "Import",
            "1 x Pallet",
            destination_transfer_line_items_with_cargo.first.description,
            "Trucking on",
            "1 x Pallet",
            on_carriage_line_items_with_cargo.first.description]
        end

        include_examples "FeeTableService results"
      end

      context "with sorted fees" do
        let(:second_line_item) do
          FactoryBot.build(:journey_line_item,
            line_item_set: line_item_set,
            route_section: freight_section,
            cargo_units: line_item.cargo_units,
            fee_code: "baf")
        end
        let(:results) { klass.perform }
        let(:line_item) { freight_line_items_with_cargo.first }
        let(:main_fee_item_index) { results.index(results.find { |r| r[:lineItemId] == second_line_item.id }) }
        let(:second_fee_item_index) { results.index(results.find { |r| r[:lineItemId] == line_item.id }) }

        before do
          line_item_set.line_items << second_line_item
        end

        it "returns rows for each level of charge table" do
          expect(main_fee_item_index < second_fee_item_index).to be_truthy
        end
      end

      context "with cargo consolidation" do
        let(:custom_scope) { { consolidation: { cargo: { backend: true } }, fee_detail: "name", default_currency: "USD" } }
        let(:cargo_class) { "lcl" }
        let(:results) { klass.perform }
        let(:expected_descriptions) do
          [nil,
            "Trucking pre",
            pre_carriage_line_items_with_cargo.first.description,
            "Export",
            origin_transfer_line_items_with_cargo.first.description,
            "Cargo",
            freight_line_items_with_cargo.first.description,
            "Import",
            destination_transfer_line_items_with_cargo.first.description,
            "Trucking on",
            on_carriage_line_items_with_cargo.first.description]
        end

        include_examples "FeeTableService results"
      end

      context "with multiple currencies" do
        let(:second_line_item) do
          FactoryBot.build(:journey_line_item,
            line_item_set: line_item_set,
            route_section: origin_transfer_section,
            fee_code: "BAF",
            description: "Bunker Adjustment Fee",
            total: Money.new(1000, "SEK"))
        end

        let(:cargo_class) { "lcl" }
        let(:results) { klass.perform }
        let(:expected_descriptions) do
          [nil,
            "Trucking pre",
            "1 x Pallet",
            pre_carriage_line_items_with_cargo.first.description,
            "Export",
            "1 x Pallet",
            origin_transfer_line_items_with_cargo.first.description,
            "Shipment",
            "Fees charged in SEK:",
            second_line_item.description,
            "Cargo",
            "1 x Pallet",
            freight_line_items_with_cargo.first.description,
            "Import",
            "1 x Pallet",
            destination_transfer_line_items_with_cargo.first.description,
            "Trucking on",
            "1 x Pallet",
            on_carriage_line_items_with_cargo.first.description]
        end

        before do
          Treasury::ExchangeRate.create(from: "USD",
                                        to: "SEK", rate: 1.2,
                                        created_at: result.created_at - 30.seconds)
          line_item_set.line_items << second_line_item
        end

        include_examples "FeeTableService results"
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
            fee_detail: "name",
            default_currency: "USD"
          }
        end
        let(:cargo_class) { "lcl" }
        let(:results) { klass.perform }
        let(:expected_descriptions) do
          [
            nil,
            "Trucking on",
            "1 x Pallet",
            on_carriage_line_items_with_cargo.first.description,
            "Cargo",
            "1 x Pallet",
            freight_line_items_with_cargo.first.description,
            "Import",
            "1 x Pallet",
            destination_transfer_line_items_with_cargo.first.description,
            "Export",
            "1 x Pallet",
            origin_transfer_line_items_with_cargo.first.description,
            "Trucking pre",
            "1 x Pallet",
            pre_carriage_line_items_with_cargo.first.description
          ]
        end

        include_examples "FeeTableService results"
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
            fee_detail: "name",
            default_currency: "USD"
          }
        end
        let(:cargo_class) { "lcl" }
        let(:results) { klass.perform }
        let(:expected_descriptions) do
          [
            nil,
            "Trucking on",
            "Cargo",
            "1 x Pallet",
            freight_line_items_with_cargo.first.description,
            "Import",
            "1 x Pallet",
            destination_transfer_line_items_with_cargo.first.description,
            "Export",
            "1 x Pallet",
            origin_transfer_line_items_with_cargo.first.description,
            "Trucking pre"
          ]
        end

        it "returns rows for each level of charge table" do
          expect(results.pluck(:description)).to eq(expected_descriptions)
        end
      end
    end

    describe ".value_with_currency" do
      let(:amount) { 10_000 }
      let(:currency) { "USD" }
      let(:money) { Money.new(amount, currency) }
      let(:format) { klass.send(:value_with_currency, money) }

      context "with complete dollar value" do
        let(:type) { :pdf }

        it "returns the value with suffix .00" do
          expect(format[:amount]).to eq("100.00")
        end
      end

      context "with raw value" do
        it "returns the raw value" do
          expect(format[:amount]).to eq(100.0)
        end
      end

      context "with finer values (pdf)" do
        let(:type) { :pdf }
        let(:amount) { 123.456789 }

        it "returns the raw value" do
          expect(format[:amount]).to eq("1.23")
        end
      end
    end

    describe ".original_value" do
      let(:edited_money) { Money.new(5555, "USD") }
      let(:format) { klass.send(:value_with_currency, money) }
      let(:line_items) { freight_line_items_with_cargo }
      let(:edited_line_item_set) { FactoryBot.create(:journey_line_item_set, result: result) }
      let(:edited_line_items) do
        freight_line_items_with_cargo.map do |line_item|
          line_item.dup.tap do |edited_line_item|
            edited_line_item.update(line_item_set: edited_line_item_set, total: edited_money)
          end
        end
      end

      it "returns the subtotal of the items provided from the original LineItemSet" do
        expect(klass.send(:original_value, items: edited_line_items, currency: "USD")).to eq(freight_line_items_with_cargo.sum(&:total))
      end
    end

    describe ".value" do
      let(:line_items) { freight_line_items_with_cargo }

      context "when the currency is the same" do
        let(:currency) { "USD" }

        it "returns the subtotal of the items provided from the original LineItemSet" do
          expect(klass.send(:value, items: line_items, currency: currency)).to eq(freight_line_items_with_cargo.sum(&:total))
        end
      end

      context "when the currency is the different" do
        let(:currency) { "EUR" }
        let(:expected_amount) do
          freight_line_items_with_cargo.inject(Money.new(0, currency)) do |sum, item|
            sum + Money.new(item.total_cents * item.exchange_rate, currency)
          end
        end

        before do
          freight_line_items_with_cargo.each { |line_item| line_item.update(exchange_rate: 1.5) }
        end

        it "returns the subtotal of the items provided from the original LineItemSet" do
          expect(klass.send(:value, items: line_items, currency: currency)).to eq(expected_amount)
        end
      end
    end
  end
end
