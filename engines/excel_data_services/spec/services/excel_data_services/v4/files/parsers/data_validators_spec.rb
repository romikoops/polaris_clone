# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Parsers::DataValidators do
  include_context "V4 setup"

  let(:service) { described_class.new(section: section_string, state: state_arguments) }

  describe "#data_validations" do
    let(:section_string) { "Trucking" }

    expected_actions = [
      ExcelDataServices::V4::Validators::DefaultTruckingDates,
      ExcelDataServices::V4::Validators::ChargeFees,
      ExcelDataServices::V4::Validators::ChargeFees, # Runs on two frames
      ExcelDataServices::V4::Validators::TruckingSheet
    ]

    it "returns all data Validations defined in the schema" do
      expect(service.data_validations.map(&:action)).to match_array(expected_actions)
    end
  end
end
