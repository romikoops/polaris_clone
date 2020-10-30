# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Validators::Trucking::Zones do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }
  let(:column_types) { ExcelDataServices::DataFrames::DataProviders::Trucking::Zones.column_types }
  let(:frame) { Rover::DataFrame.new(frame_data, types: column_types) }
  let(:frame_data) do
    [
      {"zone_row" => 4,
       "zone_col" => 3,
       "zone" => zone_value,
       "primary" => primary_value,
       "secondary" => secondary_value,
       "country_code" => country_code_value,
       "identifier" => identifier_value,
       "sheet_name" => "Sheet3"}
    ]
  end
  let(:primary_value) { nil }
  let(:secondary_value) { nil }
  let(:zone_value) { 1.0 }
  let(:zone_range_value) { "2000 - 3000" }
  let(:country_code_value) { "DE" }
  let(:optional_numeric_value) { 1000 }
  let(:optional_string_value) { "21000" }
  let(:locode_value) { "DEHAM" }
  let(:required_string_value) { "Hamburg" }
  let(:identifier_value) { "zipcode" }

  let(:errors) { result.errors }

  describe ".validate" do
    context "when the zones are locode based" do
      let(:identifier_value) { "locode" }
      let(:primary_value) { locode_value }

      it_behaves_like "locode validator"
      it_behaves_like "country_code validator"
    end

    context "when the zones are zipcode based" do
      let(:identifier_value) { "zipcode" }
      let(:primary_value) { optional_string_value }
      let(:secondary_value) { zone_range_value }

      it_behaves_like "zone validator"
      it_behaves_like "zone_range validator"
      it_behaves_like "country_code validator"
    end

    context "when the zones are distance based" do
      let(:identifier_value) { "distance" }
      let(:primary_value) { optional_numeric_value }
      let(:secondary_value) { zone_range_value }

      it_behaves_like "optional_integer_like type"
      it_behaves_like "zone_range validator"
      it_behaves_like "country_code validator"
    end

    context "when the zones are city based" do
      let(:identifier_value) { "city" }
      let(:primary_value) { required_string_value }
      let(:secondary_value) { required_string_value }

      it_behaves_like "required_string validator"
      it_behaves_like "country_code validator"
    end
  end
end
