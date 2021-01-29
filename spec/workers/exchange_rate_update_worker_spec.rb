require "rails_helper"

RSpec.describe ExchangeRateUpdateWorker, type: :worker do
  before do
    stub_request(:get, /openexchangerates/)
      .to_return(status: 200, body: oxr_response, headers: {})
    described_class.new.perform
  end

  let(:oxr_response) { File.read(File.join(Dir.pwd, "/spec/fixtures/files/oxr_rates.json")) }
  let(:oxr_rates) { JSON.parse(oxr_response).dig("rates") }
  let(:eur_usd_rate) { Treasury::ExchangeRate.find_by(from: "EUR", to: "USD") }
  let(:eur_gbp_rate) { Treasury::ExchangeRate.find_by(from: "EUR", to: "GBP") }
  let(:eur_cny_rate) { Treasury::ExchangeRate.find_by(from: "EUR", to: "CNY") }
  let(:eur_aed_rate) { Treasury::ExchangeRate.find_by(from: "EUR", to: "AED") }

  it "creates a Teasury::ExchangeRate for each result from OXR", :aggregate_failures do
    expect(eur_usd_rate.rate).to eq(oxr_rates["USD"].to_d)
    expect(eur_gbp_rate.rate).to eq(oxr_rates["GBP"].to_d)
    expect(eur_aed_rate.rate).to eq(oxr_rates["AED"].to_d)
    expect(eur_cny_rate.rate).to eq(oxr_rates["CNY"].to_d)
  end
end
