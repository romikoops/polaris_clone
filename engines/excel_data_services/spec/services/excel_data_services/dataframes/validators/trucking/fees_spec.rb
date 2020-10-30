# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Validators::Trucking::Fees do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }
  let(:column_types) { ExcelDataServices::DataFrames::DataProviders::Trucking::Fees.column_types }
  let(:frame) { Rover::DataFrame.new(frame_data, types: column_types) }
  let(:frame_data) do
    [
      {"fee" => required_string_value,
       "mot" => mode_of_transport_value,
       "fee_code" => "fsc",
       "truck_type" => truck_type_value,
       "direction" => direction_value,
       "currency" => currency_value,
       "rate_basis" => rate_basis_value,
       "ton" => nil,
       "cbm" => nil,
       "kg" => nil,
       "item" => nil,
       "shipment" => optional_numeric_value,
       "bill" => nil,
       "container" => nil,
       "minimum" => nil,
       "wm" => nil,
       "percentage" => nil,
       "sheet_name" => "Fees"}
    ]
  end
  let(:optional_numeric_value) { nil }
  let(:required_string_value) { "Fuel Surcharge Fee" }
  let(:mode_of_transport_value) { "ocean" }
  let(:currency_value) { "EUR" }
  let(:rate_basis_value) { "PER_SHIPMENT" }
  let(:direction_value) { "export" }
  let(:truck_type_value) { "default" }

  let(:errors) { result.errors }

  describe ".validate" do
    it_behaves_like "optional_numeric validator"
    it_behaves_like "mode_of_transport validator"
    it_behaves_like "currency validator"
    it_behaves_like "direction validator"
    it_behaves_like "truck_type validator"
    it_behaves_like "required_string validator"
  end
end
