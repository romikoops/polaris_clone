# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Parsers::DataValidators do
  include_context "V4 setup"

  let(:service) { described_class.new(section: section_string, state: state_arguments) }

  describe "#data_validations" do
    let(:section_string) { "Trucking" }

    it "returns all data Validations defined in the schema", :aggregate_failures do
      expect(service.data_validations).to match_array([
        ExcelDataServices::V4::Validators::ChargeFees,
        ExcelDataServices::V4::Validators::TruckingSheet
      ])
    end
  end
end
