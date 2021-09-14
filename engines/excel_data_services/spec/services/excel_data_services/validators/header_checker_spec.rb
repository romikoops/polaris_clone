# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::HeaderChecker do
  context "with faulty data" do
    let(:completely_wrong_headers) do
      %i[abc
        def]
    end
    let(:slightly_wrong_headers) do
      %i[
        status
        type
        name
        locode
        terminal
        terminal_code
        latitude
        longitude
        countryyy
        full_address
        free_out
        import_charges
        export_charges
        pre_carriage
        on_carriage
        alternative_names
      ]
    end

    before { Organizations.current_id = FactoryBot.create(:organizations_organization).id }

    describe ".validate" do
      context "with completely wrong headers (below threshold)" do
        it "logs the errors" do
          validator = described_class.new("Sheet1", completely_wrong_headers)
          validator.perform

          expect(
            validator.errors_and_warnings
          ).to eq(
            [
              {
                exception_class: ExcelDataServices::Validators::ValidationErrors::HeaderChecker,
                reason: "The type of the data sheet could not be determined. "\
                  "Please check if the column names are correct.",
                row_nr: 1,
                sheet_name: "Sheet1",
                type: :error
              }
            ]
          )
        end
      end

      context "with slightly wrong headers (above threshold)" do
        it "logs the errors" do
          validator = described_class.new("Sheet1", slightly_wrong_headers)
          validator.perform

          expect(validator.errors_and_warnings).to eq(
            [{ exception_class: ExcelDataServices::Validators::ValidationErrors::HeaderChecker,
               reason: "The following headers of sheet \"Sheet1\" are not valid:\nCorrect static headers"\
                " for this sheet are: \"STATUS, TYPE, NAME, LOCODE, LATITUDE, LONGITUDE, FULL_ADDRESS, FREE_OUT,"\
                " IMPORT_CHARGES, EXPORT_CHARGES, PRE_CARRIAGE, ON_CARRIAGE, ALTERNATIVE_NAMES\",\nMissing static"\
                " headers are               : \"COUNTRY\"",
               row_nr: 1,
               sheet_name: "Sheet1",
               type: :error }]
          )
        end
      end
    end
  end
end
