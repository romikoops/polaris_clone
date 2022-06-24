# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Operations::CountryCodeFromLocode do
  include_context "V4 setup"

  let(:operation_result) { described_class.state(state: state_arguments).frame }
  let(:rows) do
    [{
      "destination_locode" => "DEHAM",
      "origin_region" => "LATAM",
      "destination_region" => "EMEA",
      "origin_hub" => "Buenos Aires",
      "origin_locode" => "ARBUE",
      "currency" => "ARBUE"
    }, {
      "destination_locode" => "DEHAM",
      "origin_region" => "ASIA",
      "destination_region" => "EMEA",
      "origin_hub" => "Anqing",
      "origin_locode" => "CNAQG",
      "currency" => "CNAQG"
    }]
  end

  describe "#perform" do
    it "extracts the 'origin_country_code' from the 'origin_locode'" do
      expect(operation_result["origin_country_code"].to_a).to match_array(%w[CN AR])
    end

    it "extracts the 'destination_country_code' from the 'destination_locode'" do
      expect(operation_result["destination_country_code"].to_a).to match_array(%w[DE DE])
    end
  end
end
