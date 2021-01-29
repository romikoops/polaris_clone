# frozen_string_literal: true

require "rails_helper"

module ResultFormatter
  RSpec.describe ExchangeRateService, type: :service do
    let(:tender) { FactoryBot.create(:quotations_tender, amount: tender_amount) }
    let(:tender_amount) { Money.new(100, "EUR") }
    let(:line_item_amount) { Money.new(50, "AED") }
    let(:line_item_iso_code) { line_item_amount.currency.iso_code.downcase }
    let(:euro_us_rate) { 1.34 }

    before do
      Treasury::ExchangeRate.create(from: tender_amount.currency.iso_code,
                                  to: line_item_amount.currency.iso_code,
                                  rate: euro_us_rate)
      FactoryBot.create_list(:quotations_line_item, 5, tender: tender, amount: line_item_amount)
    end

    describe ".perform" do
      let(:klass) do
        described_class.new(
          base_currency: tender.amount.currency.iso_code,
          currencies: tender.line_items.pluck(:amount_currency),
          timestamp: tender.created_at
        )
      end

      context "when line items and the tender have differing currencies" do
        it "returns a hash containing the currency rates of line items" do
          result = {"base" => tender.amount.currency.iso_code, line_item_iso_code => euro_us_rate}
          expect(klass.perform).to eq(result)
        end
      end

      context "when line items and tender have the same currencies" do
        let(:tender_amount) { Money.new(100, "USD") }
        let(:line_item_amount) { Money.new(50, "USD") }

        it "returns an empty hash" do
          result = {}
          expect(klass.perform).to eq(result)
        end
      end

      context "when there are multiple rates (with varying dates)" do
        let(:rates) do
          [{rate: 2.14, created_at: tender.created_at + 2.days},
            {rate: 3.04, created_at: tender.created_at - 10.days}]
        end

        before do
          rates.each do |rate|
            Treasury::ExchangeRate.create(from: tender_amount.currency.iso_code,
                                        to: "USD", rate: rate[:rate],
                                        created_at: rate[:created_at])
          end
        end

        it "uses the rate valid at the time of creation of tender" do
          result = {"base" => tender.amount.currency.iso_code, line_item_iso_code => euro_us_rate}
          expect(klass.perform).to eq(result)
        end
      end
    end
  end
end
