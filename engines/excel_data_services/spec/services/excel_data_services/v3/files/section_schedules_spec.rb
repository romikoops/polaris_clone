# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::Section do
  include_context "V3 setup"

  let(:xlsx) { File.open(file_fixture("excel/example_schedules.xlsx")) }
  let(:section_string) { "Schedules" }
  let(:service) { described_class.new(state: state_arguments) }
  let(:sheet_name) { xlsx.sheets.first }
  let(:result_state) { service.perform }

  before do
    Organizations.current_id = organization.id
  end

  describe "#valid?" do
    it "returns successfully" do
      expect(service.valid?).to eq(true)
    end
  end

  describe "#data" do
    let(:expected_results) do
      [{ "vessel_name" => "Cap Sud",
         "row" => 2,
         "sheet_name" => "Sheet1",
         "origin_locode" => "DEHAM",
         "destination_locode" => "CNSHA",
         "origin_departure" => Date.parse("Wed, 05 Jan 2022"),
         "destination_arrival" => Date.parse("Sun, 30 Jan 2022"),
         "closing_date" => Date.parse("Sat, 01 Jan 2022"),
         "carrier" => "Hamburg Sud",
         "carrier_code" => "hamburg sud",
         "service" => "standard",
         "mode_of_transport" => "ocean",
         "vessel_code" => "CPSD-11",
         "voyage_code" => "DDFF44-E",
         "organization_id" => organization.id },
        { "vessel_name" => "Cap Nord",
          "row" => 3,
          "sheet_name" => "Sheet1",
          "origin_locode" => "DEHAM",
          "destination_locode" => "CNSHA",
          "origin_departure" => Date.parse("Sat, 05 Feb 2022"),
          "destination_arrival" => Date.parse("Sat, 05 Mar 2022"),
          "closing_date" => Date.parse("Tue, 01 Feb 2022"),
          "carrier" => "Hamburg Sud",
          "carrier_code" => "hamburg sud",
          "service" => "standard",
          "mode_of_transport" => "ocean",
          "vessel_code" => "CPSD-12",
          "voyage_code" => "DFDFF_999",
          "organization_id" => organization.id }]
    end

    it "returns a DataFrame of extracted values" do
      expect(service.data).to eq(Rover::DataFrame.new(expected_results))
    end
  end

  describe "#perform" do
    let(:carrier) { FactoryBot.create(:legacy_carrier, name: "Hamburg Sud", code: "hamburg sud") }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "standard", carrier: carrier, organization: organization) }
    let(:origin_hub) { FactoryBot.create(:legacy_hub, :hamburg, organization: organization) }
    let(:destination_hub) { FactoryBot.create(:legacy_hub, :shanghai, organization: organization) }
    let(:result_state) { service.perform }
    let(:schedule_count) { Schedules::Schedule.all.count }

    shared_examples_for "schedule creation fails" do
      it "no schedules are created" do
        expect(schedule_count).to eq 0
      end

      it "the result state contains valid error" do
        expect(result_state.errors.map(&:reason)).to include(error_reason)
      end
    end

    before do
      carrier
      tenant_vehicle
      origin_hub
      destination_hub
      result_state
    end

    it "returns a State object after inserting Data", :aggregate_failures do
      expect(result_state).to be_a(ExcelDataServices::V3::State)
    end

    context "with valid data" do
      it "creates 2 schedules" do
        expect(schedule_count).to eq 2
      end
    end

    context "with incorrect hub" do
      let(:origin_hub) { FactoryBot.create(:legacy_hub, :gothenburg, organization: organization) }
      let(:error_reason) { "The origin hub 'DEHAM' cannot be found. Please check that the information is entered correctly" }

      it_behaves_like "schedule creation fails"
    end

    context "with incorrect carrier" do
      let(:carrier) { FactoryBot.create(:legacy_carrier, name: "MSC", code: "msc") }
      let(:error_reason) { "The Carrier 'Hamburg Sud' cannot be found." }

      it_behaves_like "schedule creation fails"
    end

    context "with incorrect tenant vehicle" do
      let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "cheapest", carrier: carrier, organization: organization) }
      let(:error_reason) { "The service 'standard (Hamburg Sud)' cannot be found." }

      it_behaves_like "schedule creation fails"
    end
  end
end
