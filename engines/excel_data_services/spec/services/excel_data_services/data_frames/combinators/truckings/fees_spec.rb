# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Combinators::Truckings::Fees do
  include_context "with standard trucking setup"
  include_context "with trucking_sheet"

  before do
    Organizations.current_id = organization.id
    tenant_vehicle
  end

  let(:country_code) { country.code }
  let(:zone_count) { 3 }
  let(:country) { FactoryBot.create(:country_de) }
  let(:carrier_name) { "Gateway Cargo GmbH" }
  let(:truckings) { ::Trucking::Trucking.all }
  let(:trucking_hub_availabilities) { ::Trucking::HubAvailability.all }
  let(:trucking_type_availabilities) { ::Trucking::TypeAvailability.all }
  let(:expected_result) do
    [{ "fee" => "Fuel Surcharge",
       "mot" => "truck_carriage",
       "fee_code" => "FSC",
       "truck_type" => "default",
       "direction" => "export",
       "currency" => "EUR",
       "rate_basis" => "PER_SHIPMENT",
       "ton" => nil,
       "cbm" => nil,
       "kg" => nil,
       "item" => nil,
       "shipment" => 120.0,
       "bill" => nil,
       "container" => nil,
       "minimum" => nil,
       "wm" => nil,
       "percentage" => nil,
       "carrier" => "Gateway Cargo GmbH",
       "service" => "standard",
       "cargo_class" => "lcl",
       "zone" => 1.0,
       "organization_id" => organization.id,
       "carrier_code" => nil,
       "carriage" => "pre",
       "tenant_vehicle_id" => tenant_vehicle.id },
      { "fee" => "Fuel Surcharge",
        "mot" => "truck_carriage",
        "fee_code" => "FSC",
        "truck_type" => "default",
        "direction" => "export",
        "currency" => "EUR",
        "rate_basis" => "PER_SHIPMENT",
        "ton" => nil,
        "cbm" => nil,
        "kg" => nil,
        "item" => nil,
        "shipment" => 120.0,
        "bill" => nil,
        "container" => nil,
        "minimum" => nil,
        "wm" => nil,
        "percentage" => nil,
        "carrier" => "Gateway Cargo GmbH",
        "service" => "standard",
        "cargo_class" => "lcl",
        "zone" => 2.0,
        "organization_id" => organization.id,
        "carrier_code" => nil,
        "carriage" => "pre",
        "tenant_vehicle_id" => tenant_vehicle.id },
      { "fee" => "Fuel Surcharge",
        "mot" => "truck_carriage",
        "fee_code" => "FSC",
        "truck_type" => "default",
        "direction" => "export",
        "currency" => "EUR",
        "rate_basis" => "PER_SHIPMENT",
        "ton" => nil,
        "cbm" => nil,
        "kg" => nil,
        "item" => nil,
        "shipment" => 120.0,
        "bill" => nil,
        "container" => nil,
        "minimum" => nil,
        "wm" => nil,
        "percentage" => nil,
        "carrier" => "Gateway Cargo GmbH",
        "service" => "standard",
        "cargo_class" => "lcl",
        "zone" => 3.0,
        "organization_id" => organization.id,
        "carrier_code" => nil,
        "carriage" => "pre",
        "tenant_vehicle_id" => tenant_vehicle.id }]
  end

  describe ".frame" do
    let(:result) { described_class.state(coordinator_state: parent_arguments) }

    it "returns successfully" do
      expect(result.frame).to eq(Rover::DataFrame.new(expected_result))
    end

    context "when all fees have service zone and cargo class" do
      let(:fee_trait) { :with_all_options_set }
      let(:expected_result) do
        [{ "fee" => "Fuel Surcharge",
           "mot" => "truck_carriage",
           "fee_code" => "FSC",
           "truck_type" => "default",
           "direction" => "export",
           "currency" => "EUR",
           "rate_basis" => "PER_SHIPMENT",
           "ton" => nil,
           "cbm" => nil,
           "kg" => nil,
           "item" => nil,
           "shipment" => 100.0,
           "bill" => nil,
           "container" => nil,
           "minimum" => nil,
           "wm" => nil,
           "percentage" => nil,
           "carrier" => tenant_vehicle.carrier.name,
           "service" => tenant_vehicle.name,
           "cargo_class" => "lcl",
           "zone" => 1.0,
           "organization_id" => organization.id,
           "carrier_code" => tenant_vehicle.carrier.code,
           "carriage" => "pre",
           "tenant_vehicle_id" => tenant_vehicle.id }]
      end

      it "returns successfully" do
        expect(result.frame).to eq(Rover::DataFrame.new(expected_result))
      end
    end
  end
end
