# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::Section do
  include_context "V3 setup"

  let(:service) { described_class.new(state: state_arguments) }
  let(:sheet_name) { xlsx.sheets.first }
  let(:result_state) { service.perform }
  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:xlsx) { File.open(file_fixture("excel/example_hubs.xlsx")) }

  before do
    FactoryBot.create(:legacy_mandatory_charge)
    Organizations.current_id = organization.id
  end

  describe "#valid?" do
    let(:section_string) { "Hubs" }

    it "returns successfully" do
      expect(service.valid?).to eq(true)
    end
  end

  describe "#data" do
    shared_examples_for "returns a DataFrame populated by the columns defined in the configs" do
      it "returns a DataFrame of extracted values" do
        expect(service.data).to eq(Rover::DataFrame.new(expected_results))
      end
    end

    context "when section is Hubs" do
      let(:section_string) { "Hubs" }
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :hubs, organization: organization, default_group: default_group) }

      it_behaves_like "returns a DataFrame populated by the columns defined in the configs"
    end

    context "when section is Nexus" do
      let(:section_string) { "Nexus" }
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :nexuses, organization: organization, default_group: default_group) }

      it_behaves_like "returns a DataFrame populated by the columns defined in the configs"
    end
  end

  describe "#perform (integration test)" do
    let(:section_string) { "Hubs" }
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
    end

    it "returns a State object after inserting Data", :aggregate_failures do
      expect(result_state).to be_a(ExcelDataServices::V3::State)
      expect(hamburg_port).to be_present
      expect(sydney_port).to be_present
    end

    context "with minimal columns filled out" do
      let(:xlsx) { File.open(file_fixture("excel/example_hubs_slim.xlsx")) }

      it "returns a State object after inserting Data", :aggregate_failures do
        expect(result_state).to be_a(ExcelDataServices::V3::State)
        expect(hamburg_port.latitude).to eq(10.15)
        expect(sydney_port.latitude).to eq(-65.15)
      end
    end
  end
end
