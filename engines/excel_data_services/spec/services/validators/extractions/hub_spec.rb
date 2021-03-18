# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::Extractions::Hub do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }
  let(:frame) { Rover::DataFrame.new([row]) }
  let(:row) do
    {
      hub_id: nil
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
        reason: "The hub cannot be found. Please check that the format of the sheet matches the uploader you chose",
        row_nr: 1,
        sheet_name: nil,
        type: :error
      }
    end

    it "returns the frame with the tenant_vehicle_id", :aggregate_failures do
      expect(errors.first.exception_class).to eq(expected_error[:exception_class])
      expect(errors.first.row_nr).to eq(expected_error[:row_nr])
      expect(errors.first.type).to eq(expected_error[:type])
    end
  end
end
