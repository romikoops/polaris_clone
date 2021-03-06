# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Runners::Blocks do
  include_context "with standard trucking setup"
  include_context "with real trucking_sheet"

  before do
    Organizations.current_id = organization.id
    tenant_vehicle
    FactoryBot.create(:legacy_tenant_vehicle, name: "Faster", organization: organization, carrier: carrier)
  end

  let!(:trucking_locations) do
    ("01060".upto("01068").to_a | ["20457"]).map do |postal_code|
      FactoryBot.create(:trucking_location,
        :zipcode,
        data: postal_code,
        country: country)
    end
  end
  let(:country_code) { country.code }
  let(:country) { FactoryBot.create(:country_de) }
  let(:carrier_name) { "Gateway Cargo GmbH" }
  let(:truckings) { ::Trucking::Trucking.all }
  let(:hub_id) { hub.id }
  let(:trucking_hub_availabilities) { ::Trucking::HubAvailability.all }
  let(:trucking_type_availabilities) { ::Trucking::TypeAvailability.all }
  let(:trucking_file) { ExcelDataServices::Schemas::Files::Trucking.new(file: xlsx) }
  let(:arguments) do
    {
      hub_id: hub_id,
      group_id: group_id,
      organization_id: organization.id
    }
  end

  describe ".run" do
    context "without existing truckings" do
      let!(:result) do
        described_class.run(file: trucking_file, arguments: arguments)
      end

      it "returns successfully", :aggregate_failures do
        expect(result.dig("truckings", "created")).to eq(2)
        expect(truckings.count).to eq(2)
        expect(truckings.map { |tr| tr.rates["kg"].count }.uniq).to eq([23])
        expect(truckings.map(&:modifier).uniq).to eq(["kg"])
      end

      it "creates the necessary HubAvailabilities", :aggregate_failures do
        expect(trucking_hub_availabilities.count).to eq(1)
      end

      it "creates the necessary TypeAvailabilities", :aggregate_failures do
        expect(trucking_type_availabilities.count).to eq(1)
        expect(trucking_type_availabilities.first.load_type).to eq("cargo_item")
        expect(trucking_type_availabilities.first.carriage).to eq("pre")
        expect(trucking_type_availabilities.first.country).to eq(country)
        expect(trucking_type_availabilities.first.query_method).to eq("zipcode")
      end
    end

    context "without fees" do
      let(:xlsx) { Roo::Spreadsheet.open(file_fixture("excel/example_trucking_no_fees.xlsx").to_s) }
      let!(:result) do
        described_class.run(file: trucking_file, arguments: arguments)
      end

      it "returns successfully", :aggregate_failures do
        expect(result.dig("truckings", "created")).to eq(2)
        expect(truckings.count).to eq(2)
        expect(truckings.map(&:fees).uniq).to eq([{}])
      end
    end

    context "with existing truckings" do
      before do
        FactoryBot.create(:trucking_trucking,
          hub: hub,
          tenant_vehicle: tenant_vehicle,
          cargo_class: cargo_class,
          load_type: load_type,
          location: location,
          carriage: carriage,
          group: default_group,
          organization: organization,
          validity: old_validity)
      end

      let!(:result) do
        described_class.run(file: trucking_file, arguments: arguments)
      end
      let(:location) { trucking_locations.find { |tl| tl.data == "01067" } }
      let(:old_validity) { Range.new(Date.parse("2020/06/01"), Date.parse("2022/12/31"), exclude_end: true) }
      let(:sheet_validity) { Range.new(Date.parse("2020/09/01"), Date.parse("2021/12/31"), exclude_end: true) }
      let(:new_past_validity) { Range.new(Date.parse("2020/06/01"), Date.parse("2020/09/01"), exclude_end: true) }
      let(:new_future_validity) { Range.new(Date.parse("2021/12/31"), Date.parse("2022/12/31"), exclude_end: true) }

      it "adjusts the existing trucking validity and inserts the new ones", :aggregate_failures do
        expect(result.dig("truckings", "created")).to eq(2)
        expect(truckings.count).to eq(4)
        expect(truckings.map(&:validity).uniq).to match_array([new_past_validity, sheet_validity, new_future_validity])
      end
    end

    context "with errors" do
      let(:result) do
        described_class.run(file: trucking_file, arguments: arguments)
      end

      context "when locations dont exist" do
        let(:trucking_locations) { [] }
        let(:error) { result.dig(:errors, 0) }

        it "returns the error", :aggregate_failures do
          expect(error.exception_class).to eq(ExcelDataServices::Validators::ValidationErrors::InsertableChecks)
          expect(error.reason).to eq("The location '01067, 01060 - 01068' cannot be found.")
          expect(error.type).to eq(:warning)
        end
      end

      context "when the hub id provided is invalid" do
        let(:hub_id) { "ALL" }
        let(:error) { result.dig(:errors, 0) }

        it "returns the error", :aggregate_failures do
          expect(error.exception_class).to eq(ExcelDataServices::Validators::ValidationErrors::TypeValidity::IntegerType)
          expect(error.reason).to eq("The value: ALL of the key: hub_id is not a valid IntegerType.")
          expect(error.type).to eq(:type_error)
        end
      end
    end
  end
end
