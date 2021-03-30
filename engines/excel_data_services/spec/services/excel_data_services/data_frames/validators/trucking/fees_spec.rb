# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Validators::Trucking::Fees do
  let(:optional_numeric_value) { nil }
  let(:required_string_value) { "Fuel Surcharge Fee" }
  let(:mode_of_transport_value) { "ocean" }
  let(:currency_value) { "EUR" }
  let(:rate_basis_value) { "PER_SHIPMENT" }
  let(:direction_value) { "export" }
  let(:truck_type_value) { "default" }
  let(:cell) do
    ExcelDataServices::DataFrames::DataProviders::Cell.new(
      value: validation_value,
      label: header,
      sheet_name: "Sheet3",
      row: 1,
      col: 1
    )
  end
  let(:error) { described_class.validate(cell: cell, value: validation_value, header: header) }

  describe ".validate" do
    context "with optional_numeric values" do
      let(:validation_value) { optional_numeric_value }
      let(:header) { "ton" }

      it_behaves_like "optional_numeric validator"
    end

    context "with mode_of_transport values" do
      let(:validation_value) { mode_of_transport_value }
      let(:header) { "mode_of_transport" }

      it_behaves_like "mode_of_transport validator"
    end

    context "with currency values" do
      let(:validation_value) { currency_value }
      let(:header) { "currency" }

      it_behaves_like "currency validator"
    end

    context "with direction values" do
      let(:validation_value) { direction_value }
      let(:header) { "direction" }

      it_behaves_like "direction validator"
    end

    context "with truck_type values" do
      let(:validation_value) { truck_type_value }
      let(:header) { "truck_type" }

      it_behaves_like "truck_type validator"
    end

    context "with required_string values" do
      let(:validation_value) { required_string_value }
      let(:header) { "fee" }

      it_behaves_like "required_string validator"
    end

    context "with required_string values" do
      let(:validation_value) { rate_basis_value }
      let(:header) { "rate_basis" }

      it_behaves_like "rate_basis validator"
    end
  end
end
