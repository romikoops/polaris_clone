# frozen_string_literal: true

require "rails_helper"

module ResultFormatter
  RSpec.describe ExchangeRateService, type: :service do
    let(:euro_us_rate) { 1.34 }
    let(:base_currency) { "USD" }
    let(:line_item_currency) { "EUR" }
    let(:line_items) do
      [
        FactoryBot.create(:journey_line_item, exchange_rate: euro_us_rate, total_currency: line_item_currency)
      ]
    end

    describe ".perform" do
      let(:klass) do
        described_class.new(
          base_currency: base_currency,
          line_items: line_items
        )
      end

      context "when line items and the tender have differing currencies" do
        let(:expected_result) { {"base" => base_currency, line_item_currency.downcase => euro_us_rate } }

        it "returns a hash containing the currency rates of line items" do
          expect(klass.perform).to eq(expected_result)
        end
      end

      context "when line items and tender have the same currencies" do
        let(:base_currency) { "EUR" }
        let(:expected_result) { {} }

        it "returns an empty hash" do
          expect(klass.perform).to eq(expected_result)
        end
      end
    end
  end
end
