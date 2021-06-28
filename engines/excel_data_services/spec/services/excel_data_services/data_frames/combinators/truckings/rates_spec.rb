# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Combinators::Truckings::Rates do
  include_context "with standard trucking setup"
  include_context "with trucking_sheet"

  before do
    Organizations.current_id = organization.id
    tenant_vehicle
  end

  let(:country_code) { country.code }
  let(:country) { FactoryBot.create(:country_de) }
  let(:carrier_name) { "Gateway Cargo GmbH" }
  let(:truckings) { ::Trucking::Trucking.all }
  let(:trucking_hub_availabilities) { ::Trucking::HubAvailability.all }
  let(:trucking_type_availabilities) { ::Trucking::TypeAvailability.all }
  let(:frame_array) { result.frame.to_a }
  let(:expected_result) do
    { "value" => 1.98,
      "sheet_name" => "Rates",
      "modifier" => "kg",
      "zone" => 1.0,
      "bracket" => "0-0",
      "max" => 0.0,
      "min" => 0.0,
      "zone_minimum" => 0.0,
      "bracket_minimum" => 25,
      "currency" => "EUR",
      "load_meterage_ratio" => 1500,
      "load_meterage_hard_limit" => nil,
      "load_meterage_stackable_limit" => 5,
      "load_meterage_non_stackable_limit" => 2.5,
      "load_meterage_stackable_type" => "area",
      "load_meterage_non_stackable_type" => "ldm",
      "cbm_ratio" => 250.0,
      "scale" => "kg",
      "rate_basis" => "PER_KG",
      "base" => 1.0,
      "truck_type" => "default",
      "load_type" => "cargo_item",
      "cargo_class" => "lcl",
      "direction" => "export",
      "carrier" => tenant_vehicle.carrier.name,
      "service" => tenant_vehicle.name,
      "mode_of_transport" => "truck_carriage",
      "effective_date" => Date.parse("Tue, 01 Sep 2020"),
      "expiration_date" => Date.parse("Thu, 31 Dec 2020"),
      "group_id" => default_group.id,
      "hub_id" => hub.id,
      "organization_id" => organization.id,
      "carriage" => "pre",
      "tenant_vehicle_id" => tenant_vehicle.id }
  end

  describe ".frame" do
    let(:result) do
      described_class.state(coordinator_state: parent_arguments)
    end

    it "returns an array of objects that represent each rate with all necessary data" do
      expected_result.each do |key, frame_value|
        expect(frame_array.first[key]).to eq(frame_value)
      end
    end
  end
end
