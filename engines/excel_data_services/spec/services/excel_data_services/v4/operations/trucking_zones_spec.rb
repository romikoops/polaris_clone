# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Operations::TruckingZones do
  include_context "V4 setup"

  let(:extracted_table) { described_class.state(state: state_arguments).frame }

  describe "#data" do
    context "when the identifier is 'postal_code' and the country has defined postal codes " do
      let(:row) do
        {
          "service" => "standard",
          "row" => 3,
          "sheet_name" => "Sheet2",
          "identifier" => "postal_code",
          "postal_code" => nil,
          "range" => "01060 - 01068",
          "country_code" => "DE",
          "zone" => nil,
          "distance" => nil,
          "city" => nil,
          "province" => nil,
          "locode" => nil
        }
      end

      it "returns only the valid postal codes within that range" do
        expect(extracted_table["postal_code"].to_a).to eq(["01067"])
      end
    end

    context "when the identifier is 'postal_code' and the country has no defined postal codes" do
      let(:row) do
        {
          "service" => "standard",
          "row" => 3,
          "sheet_name" => "Sheet2",
          "identifier" => "postal_code",
          "postal_code" => nil,
          "range" => "20030 - 20035",
          "country_code" => "AT",
          "zone" => nil,
          "distance" => nil,
          "city" => nil,
          "province" => nil,
          "locode" => nil
        }
      end

      it "returns all postal codes within the defined range" do
        expect(extracted_table["postal_code"].to_a).to eq(%w[20030 20031 20032 20033 20034])
      end
    end

    context "when the identifier is 'postal_code' and the country has no defined postal codes (alphanumeric postal codes)" do
      let(:row) do
        {
          "service" => "standard",
          "row" => 3,
          "sheet_name" => "Sheet2",
          "identifier" => "postal_code",
          "postal_code" => nil,
          "range" => "BE10 - BE15",
          "country_code" => "AT",
          "zone" => nil,
          "distance" => nil,
          "city" => nil,
          "province" => nil,
          "locode" => nil
        }
      end

      it "returns all alpha numeric postal codes within the defined range" do
        expect(extracted_table["postal_code"].to_a).to eq(%w[BE10 BE11 BE12 BE13 BE14 BE15])
      end
    end

    context "when the identifier is 'distance'" do
      let(:row) do
        {
          "service" => "standard",
          "row" => 3,
          "sheet_name" => "Sheet2",
          "identifier" => "distance",
          "postal_code" => nil,
          "range" => "10 - 15",
          "country_code" => "AT",
          "zone" => nil,
          "distance" => nil,
          "city" => nil,
          "province" => nil,
          "locode" => nil
        }
      end

      it "returns distance values range" do
        expect(extracted_table["distance"].to_a).to eq(%w[10 11 12 13 14])
      end
    end

    context "when the identifier is 'postal_code' and the country has defined postal codes plus should ignore non numeric trailing characters during validation" do
      let(:row) do
        {
          "service" => "standard",
          "row" => 3,
          "sheet_name" => "Sheet2",
          "identifier" => "postal_code",
          "postal_code" => nil,
          "range" => "01060 - 01068",
          "country_code" => "NL",
          "zone" => nil,
          "distance" => nil,
          "city" => nil,
          "province" => nil,
          "locode" => nil
        }
      end

      before do
        FactoryBot.create(:trucking_postal_code,
          country: FactoryBot.create(:legacy_country, code: "NL"),
          postal_code: "01067 JX")
      end

      it "returns only the valid postal codes within that range, ignoring trailing non numerics" do
        expect(extracted_table["postal_code"].to_a).to eq(["01067"])
      end
    end
  end
end
