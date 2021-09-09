# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Files::Tables::DynamicColumns do
  include_context "for excel_data_services setup"

  let(:sheet) { ExcelDataServices::V2::Files::Tables::Sheet.new(section: section, sheet_name: sheet_name) }
  let(:section) { ExcelDataServices::V2::Files::Section.new(state: state_arguments) }
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
      let(:expected_headers) { %w[ofr lss] }
      let(:excluding) { %w[REMARKS VM_RATIO WM_RATIO TRANSIT_TIME] }
      let(:including) { [] }
      let(:header_row) { 1 }
      let(:sheet_name) { "Sheet2" }

      it_behaves_like "#columns"
    end
  end
end
