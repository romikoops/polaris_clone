# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Parsers::Columns do
  include_context "V4 setup"

  let(:service) { described_class.new(section: section_string, state: state_arguments) }
  let(:xlsx) { File.open(file_fixture("excel/example_hubs.xlsx")) }

  describe "#columns" do
    let(:section_string) { "Hubs" }

    expected_headers = %w[name
      locode
      hub_status
      hub_type
      terminal
      terminal_code
      latitude
      longitude
      country
      full_address
      free_out
      import_charges
      export_charges
      pre_carriage
      on_carriage
      alternative_names]

    it "returns all columns defined in the schema", :aggregate_failures do
      expect(service.columns.count).to eq(16)
      expect(service.columns.map(&:header)).to match_array(expected_headers)
    end

    context "when there are sheet_names configured" do
      let(:section_string) { "Trucking" }
      let(:xlsx) { File.open(file_fixture("excel/example_trucking.xlsx")) }

      it "returns all columns defined in the schema for the given sheet name" do
        expect(service.columns.count { |col| col.header == "max" }).to eq(1)
      end
    end

    context "when there are sheets configured" do
      let(:section_string) { "SacoImport" }
      let(:xlsx) { File.open(file_fixture("excel/example_saco_import.xlsx")) }

      it "returns all columns defined in the schema for the given sheet name" do
        expect(service.columns.map(&:sheet_name).uniq).to eq(["Tariff Sheet"])
      end
    end
  end

  describe "#matrixes" do
    context "when there are no Matrixes configured" do
      let(:section_string) { "LocalCharge" }

      it "returns an empty array" do
        expect(service.matrixes).to eq([])
      end
    end

    context "when there are Matrixes configured" do
      let(:section_string) { "Trucking" }

      it "returns all matrixes defined in the schema", :aggregate_failures do
        expect(service.matrixes.count).to eq(6)
        expect(service.matrixes.map(&:header)).to match_array(%w[rate row_minimum zone bracket_minimum bracket modifier])
      end
    end
  end

  describe "#dynamic_columns" do
    context "when there are no DynamicColumns configured" do
      let(:section_string) { "LocalCharge" }

      it "returns an empty array" do
        expect(service.dynamic_columns).to eq([])
      end
    end

    context "when there are DynamicColumns configured" do
      let(:section_string) { "Pricings" }

      it "returns all dynamic columns defined in the schema", :aggregate_failures do
        expect(service.dynamic_columns.count).to eq(1)
        expect(service.dynamic_columns).to be_all(ExcelDataServices::V4::Files::Tables::DynamicColumns)
      end
    end
  end

  describe "#headers" do
    let(:section_string) { "Trucking" }
    let(:expected_headers) do
      %w[
        group_name
        group_id
        service
        carrier
        carrier_code
        direction
        cargo_class
        load_type
        truck_type
        effective_date
        expiration_date
        cbm_ratio
        currency
        base
        load_meterage_stackable_limit
        load_meterage_non_stackable_limit
        load_meterage_hard_limit
        load_meterage_stackable_type
        load_meterage_non_stackable_type
        rate_basis
        mode_of_transport
        rate
        row_minimum
        zone
        bracket_minimum
        bracket
        modifier
      ]
    end

    it "returns the headers of all Matrixes and Columns defined in the schema" do
      expect(service.headers.uniq).to match_array(expected_headers)
    end
  end
end
