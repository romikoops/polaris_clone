# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::Parsers::Columns do
  include_context "V3 setup"

  let(:service) { described_class.new(section: section_string, state: state_arguments) }
  let(:xlsx) { File.open(file_fixture("excel/example_hubs.xlsx")) }

  describe "#columns" do
    let(:section_string) { "RoutingCarrier" }

    it "returns all columns defined in the schema", :aggregate_failures do
      expect(service.columns.count).to eq(2)
      expect(service.columns.map(&:header)).to match_array(%w[carrier carrier_code])
    end

    context "when the section has prerequisites" do
      let(:section_string) { "TenantVehicle" }

      it "includes the columns from the Prerequisites", :aggregate_failures do
        expect(service.columns.count).to eq(4)
        expect(service.columns.map(&:header)).to match_array(%w[carrier carrier_code mode_of_transport service])
      end
    end
  end

  describe "#matrixes" do
    context "when there are no Matrixes configured" do
      let(:section_string) { "Carrier" }

      it "returns an empty array" do
        expect(service.matrixes).to eq([])
      end
    end

    context "when there are Matrixes configured" do
      let(:section_string) { "Truckings" }

      it "returns all matrixes defined in the schema", :aggregate_failures do
        expect(service.matrixes.count).to eq(6)
        expect(service.matrixes.map(&:header)).to match_array(%w[rate row_minimum zone bracket_minimum bracket modifier])
      end
    end
  end

  describe "#dynamic_columns" do
    context "when there are no DynamicColumns configured" do
      let(:section_string) { "Carrier" }

      it "returns an empty array" do
        expect(service.dynamic_columns).to eq([])
      end
    end

    context "when there are DynamicColumns configured" do
      let(:section_string) { "Pricings" }

      it "returns all dynamic columns defined in the schema", :aggregate_failures do
        expect(service.dynamic_columns.count).to eq(1)
        expect(service.dynamic_columns).to be_all(ExcelDataServices::V3::Files::Tables::DynamicColumns)
      end
    end
  end

  describe "#headers" do
    let(:section_string) { "Truckings" }
    let(:expected_headers) do
      %w[fee_name
        fee_code
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
        modifier]
    end

    it "returns the headers of all Matrixes and Columns defined in the schema" do
      expect(service.headers).to match_array(expected_headers)
    end
  end
end
