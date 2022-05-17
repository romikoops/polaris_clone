# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Upload do
  include_context "V4 setup"

  let(:service) { described_class.new(file: file, arguments: {}) }
  let(:xlsx) { File.open(file_fixture("excel/example_hubs.xlsx")) }

  before do
    FactoryBot.create(:legacy_mandatory_charge)
  end

  describe "#perform" do
    let(:hamburg) do
      Legacy::Nexus.find_by(organization: organization,
        locode: "DEHAM",
        name: "Hamburg")
    end
    let(:hamburg_port) do
      Legacy::Hub.find_by(organization: organization,
        hub_code: "DEHAM", name: "Hamburg", terminal: nil,
        terminal_code: nil, nexus: hamburg)
    end
    let(:sydney) do
      Legacy::Nexus.find_by(organization: organization,
        locode: "AUSYD",
        name: "Sydney")
    end
    let(:sydney_port) do
      Legacy::Hub.find_by(organization: organization,
        hub_code: "AUSYD", name: "Sydney", terminal: "North Harbour", terminal_code: "SYDNHH",
        nexus: sydney)
    end

    before do
      allow(Carta::Client).to receive(:suggest).with(query: "DEHAM").and_return(
        FactoryBot.build(:carta_result, latitude: 10.15, longitude: 11.5, address: "DEHAM")
      )
      allow(Carta::Client).to receive(:reverse_geocode).with(latitude: 10.15, longitude: 11.5).and_return(
        FactoryBot.build(:carta_result, latitude: 10.15, longitude: 11.5, address: "Hamburg, Germany", country: "Germany", locality: "Hamburg")
      )
      allow(Carta::Client).to receive(:suggest).with(query: "AUSYD").and_return(
        FactoryBot.build(:carta_result, latitude: -65.15, longitude: 100.5, address: "AUSYD")
      )
      allow(Carta::Client).to receive(:reverse_geocode).with(latitude: -65.15, longitude: 100.5).and_return(
        FactoryBot.build(:carta_result, latitude: -65.15, longitude: 100.5, address: "Sydney, Australia", country: "Australia", locality: "Sydney")
      )
      FactoryBot.create(:legacy_mandatory_charge,
        pre_carriage: false, on_carriage: false, import_charges: false,
        export_charges: true)
      FactoryBot.create(:legacy_country, name: "Australia", code: "AU")
      FactoryBot.create(:legacy_country, name: "Germany", code: "DE")
      service.perform
    end

    it "successfully inserts the Hub and Nexus Data", :aggregate_failures do
      expect(hamburg).to be_present
      expect(sydney).to be_present
      expect(hamburg_port).to be_present
      expect(sydney_port).to be_present
    end

    context "with minimal columns filled out" do
      let(:xlsx) { File.open(file_fixture("excel/example_hubs_slim.xlsx")) }

      it "pulls the correct lat lngs from Carta", :aggregate_failures do
        expect(hamburg_port.latitude).to eq(10.15)
        expect(sydney_port.latitude).to eq(-65.15)
        expect(hamburg_port.longitude).to eq(11.5)
        expect(sydney_port.longitude).to eq(100.5)
      end
    end
  end

  describe "#valid?" do
    context "with an empty sheet" do
      let(:xlsx) { File.open(file_fixture("excel/empty.xlsx")) }

      it "is invalid" do
        expect(service).not_to be_valid
      end
    end

    context "with an hubs sheet" do
      let(:xlsx) { File.open(file_fixture("excel/example_hubs.xlsx")) }

      it "is valid" do
        expect(service).to be_valid
      end
    end
  end
end
