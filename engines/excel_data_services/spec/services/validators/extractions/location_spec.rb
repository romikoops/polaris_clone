# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::Extractions::Location do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }
  let(:frame) { Rover::DataFrame.new([row]) }
  let(:row) do
    {
      city: "Cape Town",
      province: "Western Cape",
      country_code: "ZA",
      location_id: nil,
      zone_row: 2,
      zone_cell: 8
    }.stringify_keys
  end
  let(:errors) { result.errors }

  before do
    Organizations.current_id = organization.id
  end

  describe ".data" do
    let(:expected_error) do
      {
        exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
        reason: "The location 'Cape Town, Western Cape' cannot be found.",
        row_nr: 2,
        sheet_name: nil,
        type: :warning
      }
    end

    it "returns the frame with the tenant_vehicle_id", :aggregate_failures do
      expect(errors.first.exception_class).to eq(expected_error[:exception_class])
      expect(errors.first.row_nr).to eq(expected_error[:row_nr])
      expect(errors.first.type).to eq(expected_error[:type])
    end
  end
end
