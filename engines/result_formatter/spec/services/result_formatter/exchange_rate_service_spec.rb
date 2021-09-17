# frozen_string_literal: true

require "rails_helper"

module ResultFormatter
  RSpec.describe ExchangeRateService, type: :service do
    let(:euro_us_rate) { 1.34 }
    let(:query_currency) { "USD" }
    let(:line_item_currency) { "EUR" }
    let(:query) { FactoryBot.create(:journey_query, currency: query_currency) }
    let(:result) { FactoryBot.build(:journey_result, query: query) }
    let(:line_item_set) { FactoryBot.build(:journey_line_item_set, result: result) }
    let(:line_items) do
      [
        FactoryBot.create(:journey_line_item, line_item_set: line_item_set, exchange_rate: euro_us_rate, total_currency: line_item_currency)
      ]
    end

    describe ".perform" do
      let(:klass) { described_class.new(line_items: line_items) }
      let(:decimals) { [line_items.first.total_cents.to_s.length, 6].max }

      context "when line items and the tender have differing currencies" do
        let(:expected_result) { { "base" => query_currency, line_item_currency.downcase => (1 / euro_us_rate).round(decimals) } }

        it "returns a hash containing the currency rates of line items" do
          expect(klass.perform).to eq(expected_result)
        end
      end

      context "when line items and tender have the same currencies" do
        let(:query_currency) { "EUR" }
        let(:expected_result) { {} }

        it "returns an empty hash" do
          expect(klass.perform).to eq(expected_result)
        end
      end
    end
  end
end
