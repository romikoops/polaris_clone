# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::SpreadsheetData do
  include_context "V3 setup"

  let(:service) { described_class.new(state: state_arguments, sheet_parser: sheet_parser) }
  let(:sheet_parser) { instance_double("ExcelDataServices::V3::Files::SheetParser", sheets: sheets) }
  let(:sheets) { ["Sheet1"] }
  let(:sheet_object_double) { instance_double(ExcelDataServices::V3::Files::Tables::Sheet, errors: errors, perform: sheet_object_frame) }
  let(:sheet_object_frame) { Rover::DataFrame.new({ "a" => [1] }) }

  before do
    allow(ExcelDataServices::V3::Files::Tables::Sheet).to receive(:new).with(state: state_arguments, sheet_name: "Sheet1", sheet_parser: sheet_parser).and_return(sheet_object_double)
  end

  describe "#frame" do
    context "when there are no errors" do
      let(:errors) { [] }

      context "when there is one Sheet object with no errors" do
        it "returns the Sheet objects DataFrame", :aggregate_failures do
          expect(service.frame).to eq(sheet_object_frame)
          expect(service.errors).to eq(errors)
        end
      end

      context "when there are multiple Sheet objects with no errors" do
        let(:second_sheet_object_double) { instance_double("ExcelDataServices::V3::Files::Sheet", errors: errors, perform: second_sheet_object_frame) }
        let(:second_sheet_object_frame) { Rover::DataFrame.new({ "a" => [2] }) }
        let(:sheets) { %w[Sheet1 Sheet2] }

        before do
          allow(ExcelDataServices::V3::Files::Tables::Sheet).to receive(:new).with(state: state_arguments, sheet_name: "Sheet2", sheet_parser: sheet_parser).and_return(second_sheet_object_double)
        end

        it "returns the Sheet objects' DataFrames concatenated together", :aggregate_failures do
          expect(service.frame).to eq(sheet_object_frame.concat(second_sheet_object_frame))
          expect(service.errors).to eq(errors)
        end
      end
    end

    context "when there is one Sheet object with errors" do
      let(:errors) { ["x"] }

      it "returns the Sheet objects DataFrame", :aggregate_failures do
        expect(service.frame).to eq(sheet_object_frame)
        expect(service.errors).to eq(errors)
      end
    end
  end
end
