# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Validators::Trucking::Metadata do
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
    context "when optional_string values" do
      let(:validation_value) { optional_string_value }
      let(:header) { "carrier" }

      it_behaves_like "optional_string validator"
    end

    context "when mode_of_transport values" do
      let(:validation_value) { mode_of_transport_value }
      let(:header) { "mode_of_transport" }

      it_behaves_like "mode_of_transport validator"
    end

    context "when currency values" do
      let(:validation_value) { currency_value }
      let(:header) { "currency" }

      it_behaves_like "currency validator"
    end

    context "when direction values" do
      let(:validation_value) { direction_value }
      let(:header) { "direction" }

      it_behaves_like "direction validator"
    end

    context "when truck_type values" do
      let(:validation_value) { truck_type_value }
      let(:header) { "truck_type" }

      it_behaves_like "truck_type validator"
    end

    context "when required_string values" do
      let(:validation_value) { required_string_value }
      let(:header) { "city" }

      it_behaves_like "required_string validator"
    end

    context "when numeric values" do
      let(:validation_value) { rate_value }
      let(:header) { "cbm_ratio" }

      it_behaves_like "numeric validator"
    end

    context "when load_type values" do
      let(:validation_value) { load_type_value }
      let(:header) { "load_type" }

      it_behaves_like "load_type validator"
    end

    context "when cargo_class values" do
      let(:validation_value) { cargo_class_value }
      let(:header) { "cargo_class" }

      it_behaves_like "cargo_class validator"
    end

    context "when modifier values" do
      let(:validation_value) { modifier_value }
      let(:header) { "modifier" }

      it_behaves_like "modifier validator"
    end

    context "when boolean values" do
      let(:validation_value) { boolean_value }
      let(:header) { "load_meterage_hard_limit" }

      it_behaves_like "boolean validator"
    end
  end
end
