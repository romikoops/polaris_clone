# frozen_string_literal: true

require "spec_helper"

RSpec.describe MoneyCache::Converter do
  let(:money_cache) { described_class.new(config: config, klass: klass) }
  let(:config) { { bank_app_id: "TEST_ID" } }
  let(:import_double) { double(failed_instances: []) }
  let(:klass) { double(import: import_double, current: rates) }
  let(:currency_rates) do
    {
      USD: 1.164415,
      GBP: 1.075166,
      CNY: 8.242079,
      EUR: 1,
      AED: 4.277129
    }
  end
  let(:base) { "EUR" }
  let(:from) { base }
  let(:to) { "GBP" }
  let(:exchange_rate) { money_cache.get_rate(from, to) }
  let(:rates) do
    currency_rates.map do |currency, rate|
      double("Treasury::ExchangeRate", from: "EUR", to: currency, rate: rate)
    end
  end

  context "with rates in store" do
    it "uses the rates existing in the store (database) to convert currencies" do
      expect(exchange_rate).to eq(currency_rates[:GBP])
    end
  end

  context "when exact rates for currencies sent are absent" do
    let(:eur_cny_rate) { 1.075166 }
    let(:from) { "CNY" }
    let(:to) { base }
    let(:expected_rate) { (1.0 / eur_cny_rate).round(6) }

    before do
      allow(money_cache.store).to receive(:get_rate).and_call_original
      allow(money_cache.store).to receive(:get_rate).with("EUR", "CNY").and_return(eur_cny_rate)
    end

    it "uses the inverse rate for conversion" do
      expect(exchange_rate).to eq(expected_rate)
    end
  end

  context "when one of the currencies is missing in store" do
    let(:from_eur_rate) { 1.075166 }
    let(:to_eur_rate) { 4.075166 }
    let(:from) { "GBP" }
    let(:to) { "CNY" }
    let(:expected_rate) { (from_eur_rate.to_d / to_eur_rate.to_d).round(6) }

    before do
      allow(money_cache.store).to receive(:get_rate).and_call_original
      allow(money_cache.store).to receive(:get_rate).with(from, base).and_return(to_eur_rate)
      allow(money_cache.store).to receive(:get_rate).with(base, to).and_return(from_eur_rate)
    end

    it "performs conversion using base currency for ABC conversion" do
      expect(exchange_rate).to eq(expected_rate)
    end
  end
end
