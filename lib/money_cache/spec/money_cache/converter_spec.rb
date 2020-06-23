# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/money_cache"

RSpec.describe MoneyCache::Converter do
  let(:money_cache) { described_class.new(config: config, klass: klass) }
  let(:config) { {bank_app_id: "TEST_ID"} }
  let(:import_double) { double(failed_instances: []) }
  let(:klass) { double(import: import_double, current: []) }

  before do
    fixture_path = File.join(Dir.pwd, "/spec/fixtures/files/oxr_rates.json")
    file_response = File.read(fixture_path)
    stub_request(:get, /openexchangerates/)
      .to_return(status: 200, body: file_response, headers: {})
  end

  context "with rates in store" do
    it "uses the rates existing in the store (database) to convert currencies" do
      rate = money_cache.get_rate("USD", "GBP")
      expect(rate.to_f).to eq(1.075166)
    end
  end

  context "when exact rates for currencies sent are absent" do
    let(:eur_cny_rate) { 1.075166 }

    before do
      allow(money_cache.store).to receive(:get_rate).and_call_original
      allow(money_cache.store).to receive(:get_rate).with("EUR", "CNY").and_return(eur_cny_rate)
    end

    it "uses the inverse rate for conversion" do
      rate = money_cache.get_rate("CNY", "EUR")
      expected_rate = 1.0 / eur_cny_rate
      expect(rate).to eq(expected_rate)
    end
  end

  context "when one of the currencies is missing in store" do
    let(:from_usd_rate) { 1.075166 }
    let(:to_usd_rate) { 4.075166 }

    before do
      allow(money_cache.store).to receive(:get_rate).and_call_original
      allow(money_cache.store).to receive(:get_rate).with("USD", "GBP").and_return(from_usd_rate)
      allow(money_cache.store).to receive(:get_rate).with("USD", "CNY").and_return(to_usd_rate)
    end

    it "performs conversion using base currency for ABC conversion" do
      rate = money_cache.get_rate("GBP", "CNY")
      expected_rate = (BigDecimal(to_usd_rate.to_s) / from_usd_rate).to_f
      expect(rate.to_f).to eq(expected_rate)
    end
  end
end
