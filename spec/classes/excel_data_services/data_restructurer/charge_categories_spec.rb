# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DataRestructurer::ChargeCategories do
  describe '.perform' do
    data = { 'Sheet1' =>
      { data_extraction_method: 'one_col_fee_and_ranges',
        rows_data: [{ internal_code: nil, fee_code: 'AMS', fee_name: 'Automated Manifest System', row_nr: 2 },
                    { internal_code: nil, fee_code: 'BAF', fee_name: 'Bunker Adjustment Factor', row_nr: 3 },
                    { internal_code: nil, fee_code: 'BAS', fee_name: 'Basic Ocean Freight', row_nr: 4 },
                    { internal_code: nil, fee_code: 'CARGO', fee_name: 'Ocean Freight', row_nr: 5 },
                    { internal_code: nil, fee_code: 'EBAF_PSS', fee_name: 'EBAF PSS', row_nr: 6 },
                    { internal_code: nil, fee_code: 'EBS', fee_name: 'Emergency Bunker Surcharge', row_nr: 7 },
                    { internal_code: nil, fee_code: 'EFS/EBS', fee_name: 'EFS/EBS', row_nr: 8 },
                    { internal_code: nil, fee_code: 'EXPORT', fee_name: 'Origin Local Charges', row_nr: 9 },
                    { internal_code: nil, fee_code: 'ISPS', fee_name: 'Ship and Port Facility Security ', row_nr: 10 },
                    { internal_code: nil, fee_code: 'OCEAN_FREIGHT', fee_name: 'Ocean Freight', row_nr: 11 },
                    { internal_code: nil, fee_code: 'OFT', fee_name: 'OFT', row_nr: 12 },
                    { internal_code: nil, fee_code: 'OTHER_CHARGES', fee_name: 'Other Charges', row_nr: 13 },
                    { internal_code: nil, fee_code: 'THC', fee_name: 'Container Service Charges', row_nr: 14 },
                    { internal_code: nil, fee_code: 'IMPORT', fee_name: 'Destination Local Charges', row_nr: 15 }] } }
    let(:tenant) { create(:tenant) }
    let(:klass_identifier) { 'ChargeCategories' }

    it 'extracts the row data from the sheet hash' do
      result = described_class.restructure_data(tenant: tenant, klass_identifier: klass_identifier, data: data)
      expect(result).to eq(data.dig('Sheet1', :rows_data))
      expect(result.length).to be(14)
      expect(result.class).to be(Array)
    end
  end
end
