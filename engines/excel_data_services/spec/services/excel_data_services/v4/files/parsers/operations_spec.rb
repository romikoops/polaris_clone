# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Parsers::Operations do
  include_context "V4 setup"

  let(:service) { described_class.new(section: section_string, state: state_arguments) }

  describe "#operations" do
    let(:section_string) { "Pricings" }

    it "returns all Operations defined in the schema" do
      expect(service.operations.map(&:action)).to eq([ExcelDataServices::V4::Operations::ExpandedDates, ExcelDataServices::V4::Operations::DynamicFees])
    end

    context "when there are no operations" do
      let(:section_string) { "Schedules" }

      it "returns an empty array" do
        expect(service.operations).to eq([])
      end
    end
  end
end
