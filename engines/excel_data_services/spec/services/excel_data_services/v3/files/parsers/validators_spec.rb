# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::Parsers::Validators do
  include_context "V3 setup"

  let(:service) { described_class.new(section: section_string, state: state_arguments) }

  describe "#data_validations" do
    let(:section_string) { "Truckings" }

    it "returns all data Validations defined in the schema", :aggregate_failures do
      expect(service.data_validations).to match_array([
        ExcelDataServices::V3::Validators::ChargeFees,
        ExcelDataServices::V3::Validators::TruckingSheet
      ])
    end
  end

  describe "#row_validations" do
    let(:section_string) { "Schedules" }

    it "returns all Row Validations defined in the schema", :aggregate_failures do
      expect(service.row_validations.map(&:class)).to match_array([ExcelDataServices::V3::Files::RowValidation] * 2)
      expect(service.row_validations.map(&:keys)).to match_array([%w[origin_departure destination_arrival], %w[closing_date origin_departure]])
    end
  end
end
