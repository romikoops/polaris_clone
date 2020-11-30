# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Validators::Trucking::Metadata do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }
  let(:column_types) { ExcelDataServices::DataFrames::DataProviders::Trucking::Metadata.column_types }
  let(:frame) { Rover::DataFrame.new(frame_data, types: column_types) }
  let(:frame_data) do
    [
      {"city" => required_string_value,
       "currency" => currency_value,
       "load_meterage_ratio" => optional_rate_value,
       "load_meterage_limit" => optional_rate_value,
       "load_meterage_area" => optional_rate_value,
       "load_meterage_hard_limit" => boolean_value,
       "load_meterage_stacking" => boolean_value,
       "cbm_ratio" => rate_value,
       "scale" => modifier_value,
       "rate_basis" => rate_basis_value,
       "base" => rate_value,
       "truck_type" => truck_type_value,
       "load_type" => load_type_value,
       "cargo_class" => cargo_class_value,
       "direction" => direction_value,
       "carrier" => optional_string_value,
       "mode_of_transport" => mode_of_transport_value,
       "service" => nil,
       "sheet_name" => "Sheet3"}
    ]
  end
  let(:optional_rate_value) { nil }
  let(:optional_string_value) { "Gateway Cargo GmbH" }
  let(:required_string_value) { "Hamburg" }
  let(:mode_of_transport_value) { "ocean" }
  let(:currency_value) { "EUR" }
  let(:rate_basis_value) { "PER_SHIPMENT" }
  let(:direction_value) { "export" }
  let(:truck_type_value) { "default" }
  let(:load_type_value) { "cargo_item" }
  let(:cargo_class_value) { "lcl" }
  let(:modifier_value) { "kg" }
  let(:rate_value) { 250 }
  let(:boolean_value) { false }

  let(:errors) { result.errors }

  describe ".validate" do
    it_behaves_like "optional_string validator"
    it_behaves_like "mode_of_transport validator"
    it_behaves_like "currency validator"
    it_behaves_like "direction validator"
    it_behaves_like "truck_type validator"
    it_behaves_like "required_string validator"
    it_behaves_like "numeric validator"
    it_behaves_like "load_type validator"
    it_behaves_like "cargo_class validator"
    it_behaves_like "modifier validator"
    it_behaves_like "boolean validator"
  end
end
