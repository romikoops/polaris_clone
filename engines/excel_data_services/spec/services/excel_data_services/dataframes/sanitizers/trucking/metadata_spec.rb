# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Sanitizers::Trucking::Metadata do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }
  let(:column_types) { ExcelDataServices::DataFrames::DataProviders::Trucking::Metadata.column_types }
  let(:frame) { Rover::DataFrame.new(frame_data, types: column_types) }
  let(:frame_data) do
    [
      {"city" => "Hamburg ",
       "currency" => "eur",
       "load_meterage_ratio" => "1500",
       "load_meterage_limit" => "4.765",
       "load_meterage_area" => "2.2",
       "load_meterage_hard_limit" => nil,
       "load_meterage_stacking" => "t",
       "cbm_ratio" => "250.0",
       "scale" => "KG",
       "rate_basis" => "per_shipment",
       "base" => 1,
       "truck_type" => "DEFault",
       "load_type" => "cargo_item ",
       "cargo_class" => "LCL ",
       "direction" => "Export ",
       "carrier" => "Gateway Cargo GmbH ",
       "service" => nil,
       "sheet_name" => "Sheet3"}
    ]
  end
  let(:result_frame) { Rover::DataFrame.new(expected_result, types: column_types) }
  let(:today) { Time.zone.today }

  describe ".sanitize" do
    let(:expected_result) do
      [{"city" => "Hamburg",
        "currency" => "EUR",
        "load_meterage_ratio" => 1500.0,
        "load_meterage_limit" => 4.765,
        "load_meterage_area" => 2.2,
        "load_meterage_hard_limit" => false,
        "load_meterage_stacking" => true,
        "cbm_ratio" => 250.0,
        "scale" => "kg",
        "rate_basis" => "PER_SHIPMENT",
        "base" => 1.0,
        "truck_type" => "default",
        "load_type" => "cargo_item",
        "cargo_class" => "lcl",
        "direction" => "export",
        "carrier" => "Gateway Cargo GmbH",
        "service" => "standard",
        "sheet_name" => "Sheet3",
        "group_id" => default_group.id,
        "identifier_modifier" => false,
        "mode_of_transport" => "truck_carriage",
        "effective_date" => today,
        "expiration_date" => today + 1.year}]
    end

    it "returns the sanitized data" do
      expect(result.frame == result_frame).to be
    end
  end
end
