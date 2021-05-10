# frozen_string_literal: true

require "spec_helper"

RSpec.describe MoneyCache::Converter do
  let(:money_cache) { described_class.new(config: { bank_app_id: "TEST_ID" }, klass: klass) }
  # rubocop:disable  RSpec/VerifiedDoubles
  let(:klass) { class_double("Treasury::ExchangeRate", import: double(failed_instances: []), current: rates) }
  # rubocop:enable  RSpec/VerifiedDoubles
  let(:base) { "EUR" }
  let(:from) { base }
  let(:to) { "GBP" }
  let(:exchange_rate) { money_cache.get_rate(from, to) }

  context "with rates in store" do
    let(:eur_gbp_rate) { 1.075166 }
    let(:rates) { [instance_double("Treasury::ExchangeRate", from: base, to: to, rate: eur_gbp_rate)] }

    it "uses the rates existing in the store (database) to convert currencies" do
      expect(exchange_rate).to eq(eur_gbp_rate)
    end
  end

  context "when exact rates for currencies sent are absent" do
    let(:eur_cny_rate) { 1.075166 }
    let(:from) { "CNY" }
    let(:to) { base }
    let(:expected_rate) { (1.0 / eur_cny_rate).round(6) }
    let(:rates) { [instance_double("Treasury::ExchangeRate", from: base, to: from, rate: eur_cny_rate)] }

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
    let(:rates) do
      [
        instance_double("Treasury::ExchangeRate", from: from, to: base, rate: from_eur_rate),
        instance_double("Treasury::ExchangeRate", from: base, to: to, rate: to_eur_rate)
      ]
    end

    it "performs conversion using base currency for ABC conversion" do
      expect(exchange_rate).to eq(expected_rate)
    end
  end
end
