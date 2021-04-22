# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Restructurers::Truckings::Metadata do
  include_context "with standard trucking setup"

  let(:modifiers) { %w[kg cbm] }
  let(:sheet_names) { ["Rates"] }
  let(:input_rows) do
    modifiers.map do |modifier|
      { "load_meterage_hard_limit" => false,
        "identifier_modifier" => 0,
        "currency" => "EUR",
        "load_meterage_ratio" => 1500,
        "load_meterage_stackable_type" => "area",
        "load_meterage_non_stackable_type" => "ldm",
        "load_meterage_stackable_limit" => 3.5,
        "load_meterage_non_stackable_limit" => 2.5,
        "cbm_ratio" => 333.0,
        "scale" => "cbm_kg",
        "rate_basis" => "PER_CBM_KG",
        "truck_type" => "default",
        "load_type" => "cargo_item",
        "cargo_class" => "lcl",
        "direction" => "export",
        "carrier" => "Combimar",
        "service" => "standard",
        "effective_date" => Time.zone.today,
        "expiration_date" => Time.zone.today + 1.year,
        "mode_of_transport" => "truck_carriage",
        "sheet_name" => "Rates",
        "carriage" => "pre",
        "tenant_vehicle_id" => 1,
        "modifier_row" => 3,
        "modifier_col" => 3,
        "modifier" => modifier,
        "group_id" => default_group.id,
        "hub_id" => hub.id,
        "organization_id" => organization.id,
        "base" => 1.0 }
    end
  end
  let(:expected_result) do
    [{ "cbm_ratio" => 333.0,
       "group_id" => default_group.id,
       "hub_id" => hub.id,
       "organization_id" => organization.id,
       "carriage" => "pre",
       "cargo_class" => "lcl",
       "load_type" => "cargo_item",
       "tenant_vehicle_id" => 1,
       "truck_type" => "default",
       "sheet_name" => "Rates",
       "load_meterage" => { "ratio" => 1500, "stackable_type" => "area", "non_stackable_type" => "ldm", "hard_limit" => false, "stackable_limit" => 3.5, "non_stackable_limit" => 2.5 },
       "identifier_modifier" => Float::NAN,
       "modifier" => "cbm_kg",
       "validity" => "[#{Time.zone.today}, #{Time.zone.today + 1.year})" }]
  end

  before do
    Organizations.current_id = organization.id
  end

  describe ".data" do
    let(:result) do
      described_class.data(
        frame: Rover::DataFrame.new(input_rows, types: ExcelDataServices::DataFrames::DataProviders::Trucking::Metadata.column_types)
      )
    end

    it "returns a single metadata row for a complex weight scale (CBM_KG) sheet" do
      expect(result.to_a.first.inspect).to match(expected_result.first.inspect)
    end
  end
end
