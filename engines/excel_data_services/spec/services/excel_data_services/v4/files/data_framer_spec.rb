# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::DataFramer do
  include_context "V4 setup"

  let(:service) { described_class.new(state: state_arguments, section_parser: section_parser) }
  let(:section_parser) { instance_double(ExcelDataServices::V4::Files::SectionParser, framer: ExcelDataServices::V4::Framers::Table) }
  let(:framer_double) { instance_double(ExcelDataServices::V4::Framers::Table, perform: framed_data, errors: errors) }
  let(:result_state) { service.perform }
  let(:framed_data) do
    Rover::DataFrame.new({
      "header_a" => %w[a a2],
      "header_b" => %w[b b2],
      "sheet_name" => ["Sheet1"] * 2,
      "row" => [1, 2]
    })
  end

  describe "#perform" do
    before { allow(ExcelDataServices::V4::Framers::Table).to receive(:new).and_return(framer_double) }

    let(:errors) { [] }

    it "returns the cell data in denormalized form" do
      expect(result_state.frame).to eq(framed_data)
    end

    context "when there are errors on the spreadsheet" do
      let(:errors) { ["x"] }

      it "appends the errors to state" do
        expect(result_state.errors).to eq(errors)
      end
    end
  end
end
