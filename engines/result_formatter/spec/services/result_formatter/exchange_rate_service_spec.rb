# frozen_string_literal: true

require "rails_helper"

module ResultFormatter
  RSpec.describe ExchangeRateService, type: :service do
    let(:euro_us_rate) { 1.34 }
    let(:result_set_currency) { "USD" }
    let(:line_item_currency) { "EUR" }
    let(:result_set) { FactoryBot.create(:journey_result_set, currency: result_set_currency) }
    let(:result) { FactoryBot.build(:journey_result, result_set: result_set) }
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
        let(:expected_result) { { "base" => result_set_currency, line_item_currency.downcase => (1 / euro_us_rate).round(decimals) } }

        it "returns a hash containing the currency rates of line items" do
          expect(klass.perform).to eq(expected_result)
        end
      end

      context "when line items and tender have the same currencies" do
        let(:result_set_currency) { "EUR" }
        let(:expected_result) { {} }

        it "returns an empty hash" do
          expect(klass.perform).to eq(expected_result)
        end
      end
    end
  end
end
