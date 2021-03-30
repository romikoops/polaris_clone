# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Importers::Trucking do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:hub) { FactoryBot.create(:legacy_hub, organization: organization) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:trucking_location) { FactoryBot.create(:trucking_location) }
  let(:trucking_params) do
    {
      "cargo_class" => "lcl",
      "carriage" => "pre",
      "cbm_ratio" => 460,
      "fees" => { "PUF" => { "key" => "PUF",
                             "name" => "Pickup Fee",
                             "value" => 250.0,
                             "min" => 250.0,
                             "currency" => "CNY",
                             "rate_basis" => "PER_SHIPMENT" } },
      "group_id" => nil,
      "hub_id" => hub.id,
      "identifier_modifier" => nil,
      "load_meterage" => { "ratio" => 1850.0, "height_limit" => 130 },
      "load_type" => "cargo_item",
      "location_id" => trucking_location.id,
      "metadata" => {},
      "modifier" => "kg",
      "organization_id" => organization.id,
      "rates" => rates,
      "tenant_vehicle_id" => tenant_vehicle.id,
      "truck_type" => "default"
    }
  end
  let(:rates) do
    { "kg" =>
      [{ "rate" => { "base" => 100.0, "value" => 237.5, "currency" => "SEK", "rate_basis" => "PER_X_KG" },
         "max_kg" => "200.0",
         "min_kg" => "0.1",
         "min_value" => 400.0 }] }
  end
  let(:data) do
    Rover::DataFrame.new([trucking_params])
  end
  let(:options) { { organization: organization, data: data, options: {} } }
  let(:stats) { described_class.import(data: data, type: "truckings") }

  describe ".import" do
    context "when no truckings exist" do
      it "successfuly imports the data" do
        expect(stats.created).to eq(1)
      end
    end

    context "when data is invalid" do
      let(:tenant_vehicle) { FactoryBot.build(:legacy_tenant_vehicle, organization: organization) }
      let(:expected_errors) { [{ sheet_name: "truckings", reason: "Tenant vehicle must exist" }] }

      it "successfuly upserts the data" do
        expect(stats.errors).to match_array(expected_errors)
      end
    end
  end
end
