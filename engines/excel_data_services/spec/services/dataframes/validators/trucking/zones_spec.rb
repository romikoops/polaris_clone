# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Validators::Trucking::Zones do
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

  let(:cell) {
    ExcelDataServices::DataFrames::DataProviders::Cell.new(
      value: validator_value,
      label: header,
      sheet_name: "Sheet3",
      row: 1,
      col: 1
    )
  }
  let(:error) { described_class.validate(cell: cell, value: validator_value, header: header) }

  describe ".validate" do
    context "with locode values" do
      let(:header) { "primary_locode" }
      let(:validator_value) { locode_value }

      it_behaves_like "locode validator"
    end

    context "with country code values" do
      let(:header) { "country_code" }
      let(:validator_value) { country_code_value }

      it_behaves_like "country_code validator"
    end

    context "when the zones are zipcode based" do
      let(:header) { "secondary_zipcode" }
      let(:validator_value) { zone_range_value }

      it_behaves_like "zone_range validator"
    end

    context "when the zones are distance based" do
      let(:header) { "primary_distance" }
      let(:validator_value) { optional_numeric_value }

      it_behaves_like "optional_integer_like type"
    end

    context "when the zones are city based" do
      let(:header) { "primary_city" }
      let(:validator_value) { required_string_value }

      it_behaves_like "required_string validator"
    end
  end
end
