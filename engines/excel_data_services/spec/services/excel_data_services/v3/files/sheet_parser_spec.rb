# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::SheetParser do
  include_context "V3 setup"

  let(:xlsx) { File.open(file_fixture("excel/example_trucking.xlsx")) }
  let(:service) { described_class.new(section: section_string, state: state_arguments, type: :section) }

  describe "#non_empty_sheets" do
    let(:section_string) { "Truckings" }

    it "returns the names on non empty sheets" do
      expect(service.non_empty_sheets).to match_array(["Zones", "Fees", "Sheet3", "Sheet4"])
    end

    context "when all sheets are empty" do
      let(:xlsx) { File.open(file_fixture("excel/empty.xlsx")) }

      it "returns an empty array" do
        expect(service.non_empty_sheets).to match_array([])
      end
    end
  end
end