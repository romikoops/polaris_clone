# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::MissingValues::LocalCharges do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:validator) { described_class.new(organization: organization, sheet_name: "Sheet1", data: data) }
  let(:data) { FactoryBot.build(:excel_data_restructured_faulty_local_charges) }

  before { FactoryBot.create(:pricings_rate_basis, internal_code: "PER_SINGLE_TON") }

  describe ".perform" do
    it "detects unknown rate basis and missing values rate basis" do
      validator.perform
      expect(validator.valid?).to be(false)
      expect(validator.results).to match_array(
        [
          { exception_class:
              ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValueForFeeComponents,
            reason: "Missing value for FEE_CODE.",
            row_nr: "2",
            sheet_name: "Sheet1",
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::UnknownRateBasis,
            reason: 'The rate basis "PER_WRONG" is unknown.',
            row_nr: "2",
            sheet_name: "Sheet1",
            type: :error },
          { exception_class:
              ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValueForFeeComponents,
            reason: "Missing value for CURRENCY.",
            row_nr: "2",
            sheet_name: "Sheet1",
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValueForRateBasis,
            reason: "Missing value for PER_SHIPMENT.",
            row_nr: "2",
            sheet_name: "Sheet1",
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValueForRateBasis,
            reason: "Missing value for PER_BILL.",
            row_nr: "2",
            sheet_name: "Sheet1",
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValueForRateBasis,
            reason: "Missing value for PER_WM_RANGE.",
            row_nr: "2",
            sheet_name: "Sheet1",
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValueForRateBasis,
            reason: "Missing value for PER_CBM_KG.",
            row_nr: "2",
            sheet_name: "Sheet1",
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValueForRateBasis,
            reason: "Missing value for PER_CBM_TON.",
            row_nr: "2",
            sheet_name: "Sheet1",
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValueForRateBasis,
            reason: "Missing value for PER_BILL_CONTAINER.",
            row_nr: "2",
            sheet_name: "Sheet1",
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValueForRateBasis,
            reason: "Missing value for PER_X_KG_FLAT.",
            row_nr: "2",
            sheet_name: "Sheet1",
            type: :error }
        ]
      )
    end
  end
end
