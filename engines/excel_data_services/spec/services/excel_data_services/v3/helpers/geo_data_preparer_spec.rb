# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Helpers::GeoDataPreparer do
  let(:raw_data) { { primary: "Cape Town", secondary: "Western Cape", country_code: "ZA" }.stringify_keys }
  let(:results) { described_class.data(identifier: identifier, raw_data: raw_data) }

  describe ".data" do
    context "when the identifier is location" do
      let(:identifier) { "city" }

      it "returns the correct structure", :aggregate_failures do
        expect(results.keys).to match_array(%i[terms country_code])
        expect(results[:terms]).to be_a(Array)
      end
    end

    context "when the identifier is nested_city" do
      let(:identifier) { "nested_city" }

      it "returns the correct structure", :aggregate_failures do
        expect(results.keys).to match_array(%i[city province country_code])
      end
    end

    context "when the identifier is locode" do
      let(:identifier) { "locode" }
      let(:raw_data) { { locode: "ZACPT", country_code: "ZA" }.stringify_keys }

      it "returns the correct structure", :aggregate_failures do
        expect(results.keys).to match_array(%i[locode])
      end
    end

    context "when the identifier is postal_city" do
      let(:identifier) { "postal_city" }
      let(:raw_data) { { city: "7795 - Cape Town", province: "Western Cape", country_code: "ZA" }.stringify_keys }

      it "returns the correct structure", :aggregate_failures do
        expect(results.keys).to match_array(%i[postal_code terms country_code])
        expect(results[:terms]).to eq(["CAPE TOWN"])
        expect(results[:postal_code]).to eq("7795")
      end
    end
  end
end
