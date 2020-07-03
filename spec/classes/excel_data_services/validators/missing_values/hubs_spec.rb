# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Validators::MissingValues::Hubs do
  let(:organization) { create(:organizations_organization) }
  let(:validator) { described_class.new(organization: organization, data: data, sheet_name: 'Sheet1') }
  let(:data) { build(:missing_values_hubs_row_data, organization: organization) }

  describe '.perform' do
    it 'detects unknown rate basis and missing values rate basis' do
      validator.perform
      expect(validator.valid?).to be(false)
      expect(validator.results).to match_array(
        [
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValuesForHub,
            reason: 'Missing value for LATITUDE.',
            sheet_name: 'Sheet1',
            row_nr: 3,
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValuesForHub,
            reason: 'Missing value for FULL ADDRESS.',
            sheet_name: 'Sheet1',
            row_nr: 2,
            type: :error },
          { exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues::MissingValuesForHub,
            reason: 'Missing value for LOCODE.',
            sheet_name: 'Sheet1',
            row_nr: 3,
            type: :error }
        ]
      )
    end
  end
end
