# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Runners::Blocks do
  let(:xlsx) { Roo::Spreadsheet.open(file_fixture("excel/example_hubs.xlsx").to_s) }
  let(:hubs) { ::Legacy::Hub.all }
  let(:nexii) { ::Legacy::Nexus.all }
  let(:hub_file) { ExcelDataServices::Schemas::Files::Hubs.new(file: xlsx) }
  let(:arguments) do
    {
      organization_id: organization.id
    }
  end
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:australia) { FactoryBot.create(:legacy_country, code: "AU", name: "Australia") }
  let!(:germany) { FactoryBot.create(:legacy_country, code: "DE", name: "Germany") }

  before do
    FactoryBot.create(:legacy_mandatory_charge)
    Organizations.current_id = organization.id
    Geocoder::Lookup::Test.add_stub([-33.85,	151.2], [
      "address_components" => [{ "types" => ["premise"] }],
      "address" => "Unnamed Road, New South Wales, Australia",
      "city" => "Sydney",
      "country" => "Australia",
      "country_code" => "AU",
      "postal_code" => ""
    ])
    Geocoder::Lookup::Test.add_stub([53.531121,	10.020287], [
      "address_components" => [{ "types" => ["premise"] }],
      "address" => "Flughafenstr. 1-3, 22335 Hamburg, Germany",
      "city" => "Hamburg",
      "country" => "Germany",
      "country_code" => "DE",
      "postal_code" => ""
    ])
  end

  describe ".run" do
    shared_examples_for "successfully uploads the sample sheet" do
      it "returns successfully", :aggregate_failures do
        expect(hubs.pluck(:hub_code)).to match_array(%w[DEHAM AUSYD])
        expect(nexii.pluck(:locode)).to match_array(%w[DEHAM AUSYD])
      end
    end

    context "without existing hubs" do
      before do
        described_class.run(file: hub_file, arguments: arguments)
      end

      it_behaves_like "successfully uploads the sample sheet"
    end

    context "with existing nexuses" do
      before do
        FactoryBot.create(:legacy_nexus, organization: organization, locode: "AUSYD", name: "Sydney", country: australia)
        FactoryBot.create(:legacy_nexus, organization: organization, locode: "DEHAM", name: "Hamburg", country: germany)
        described_class.run(file: hub_file, arguments: arguments)
      end

      it_behaves_like "successfully uploads the sample sheet"
    end

    context "with existing hubs" do
      before do
        FactoryBot.create(:legacy_hub,
          organization: organization,
          hub_code: "AUSYD",
          name: "Sydney",
          terminal: "North Harbour",
          terminal_code: "SYDNHH",
          nexus: FactoryBot.build(:legacy_nexus,
            organization: organization,
            locode: "AUSYD",
            name: "Sydney",
            country: australia))
        FactoryBot.create(:legacy_hub,
          organization: organization,
          hub_code: "DEHAM",
          name: "Hamburg",
          nexus: FactoryBot.build(:legacy_nexus,
            organization: organization,
            locode: "DEHAM",
            name: "Hamburg",
            country: germany))
        described_class.run(file: hub_file, arguments: arguments)
      end

      it_behaves_like "successfully uploads the sample sheet"
    end
  end
end
