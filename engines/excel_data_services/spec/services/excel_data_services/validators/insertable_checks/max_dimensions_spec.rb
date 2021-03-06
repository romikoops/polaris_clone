# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::InsertableChecks::MaxDimensions do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:options) { { organization: organization, sheet_name: "Sheet1", data: input_data } }

  context "with faulty data" do
    let(:input_data) do
      [{
        sheet_name: "Sheet1",
        restructurer_name: "max_dimensions",
        carrier: "msc",
        service_level: "standard",
        mode_of_transport: nil,
        width: 0.1e4,
        length: 0.9e3,
        height: 0.12e4,
        payload_in_kg: 0.1e5,
        chargeable_weight: 0.1e5,
        load_type: "blah",
        aggregate: "blues",
        origin_locode: "DEBLT",
        destination_locode: "CNTAH",
        row_nr: 2
      }].map { |row| ExcelDataServices::Rows::MaxDimensions.new(organization: organization, row_data: row) }
    end
    let(:validator) { described_class.new(options) }

    describe ".validate" do
      before do
        validator.perform
      end

      let(:expected_errors) do
        [
          { exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
            reason: "The provided load type is invalid",
            row_nr: 2,
            sheet_name: "Sheet1",
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
            reason: "Aggregate can only be either True/False",
            row_nr: 2,
            sheet_name: "Sheet1",
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
            reason: "No hub exists with the LOCODE DEBLT",
            row_nr: 2,
            sheet_name: "Sheet1",
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
            reason: "No hub exists with the LOCODE CNTAH",
            row_nr: 2,
            sheet_name: "Sheet1",
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
            reason: "A valid mode of transport is required if assigning to a route",
            row_nr: 2,
            sheet_name: "Sheet1",
            type: :error }
        ]
      end

      it "logs the errors" do
        expect(validator.results).to match_array(expected_errors)
      end
    end
  end
end
