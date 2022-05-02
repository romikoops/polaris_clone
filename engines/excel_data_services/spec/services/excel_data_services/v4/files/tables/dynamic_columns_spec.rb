# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Tables::DynamicColumns do
  include_context "V4 setup"

  let(:sheet) { ExcelDataServices::V4::Files::Tables::Sheet.new(state: state_arguments, sheet_name: sheet_name, section_parser: section_parser) }
  let(:section_parser) { ExcelDataServices::V4::Files::SectionParser.new(section: section_string, state: state_arguments) }
  let(:dynamic_columns) { described_class.new(excluding: excluding, including: including, header_row: header_row).columns(sheet: sheet) }

  before do
    Organizations.current_id = organization.id
  end

  describe "#columns" do
    let(:section_string) { "Pricings" }

    shared_examples_for "#columns" do
      it "returns the Columns generated from the Dynamic Headers", :aggregate_failures do
        expect(dynamic_columns.map(&:header)).to match_array(expected_headers)
      end
    end

    context "when no dynamic columns exists" do
      let(:expected_headers) { [] }
      let(:excluding) { %w[REMARKS VM_RATIO WM_RATIO] }
      let(:including) { [] }
      let(:header_row) { 1 }
      let(:sheet_name) { "Sheet1" }

      it_behaves_like "#columns"
    end

    context "when two dynamic columns exists" do
      let(:expected_headers) { %w[Dynamic:ofr Dynamic:lss] }
      let(:excluding) { %w[REMARKS VM_RATIO WM_RATIO TRANSIT_TIME] }
      let(:including) { [] }
      let(:header_row) { 1 }
      let(:sheet_name) { "Sheet2" }

      it_behaves_like "#columns"
    end

    context "when defining the columns to be included" do
      let(:expected_headers) { %w[Dynamic:ofr] }
      let(:excluding) { %w[REMARKS VM_RATIO WM_RATIO TRANSIT_TIME] }
      let(:including) { ["OFR"] }
      let(:header_row) { 1 }
      let(:sheet_name) { "Sheet2" }

      it_behaves_like "#columns"
    end
  end
end
