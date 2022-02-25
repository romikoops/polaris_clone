# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trucking::PostalCodes do
  describe ".for" do
    let(:country_code) { "de" }
    let(:postal_codes) { described_class.for(country_code: country_code) }

    context "when the data exists" do
      it "returns the postal codes in an array" do
        expect(postal_codes).not_to be_empty
      end
    end
  end

  describe ".country_codes" do
    let(:country_codes) { described_class.country_codes }

    it "returns the country codes in an array" do
      expect(country_codes).to match_array(["gb", "se", "nl", "de"])
    end
  end

  describe ".all" do
    let(:results) { described_class.all }

    it "returns the postal codes with country codes in an array", :aggregate_failures do
      expect(results.length).to eq(31192)
      expect(results.first.keys).to match_array(["postal_code", "country_code"])
    end
  end
end
