# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/file_parser'

RSpec.describe ExcelDataServices::FileParser::Base do
  before(:all) { @path_to_files = file_fixture('excel') }
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, file_or_path: file_or_path } }

  describe '.parse' do
    include_examples 'parse excel sheet successfully' do
      let(:file_or_path) do
        @path_to_files.join('determine_data_extraction_method.xlsx')
      end
      let(:correctly_parsed_data) do
        { 'Sheet1' => { data_extraction_method: 'one_col_fee_and_ranges',
                        rows_data: [
                          { fee_code: 'BAS', some_test_date: Date.parse('01 Jan 2019'), row_nr: 2 }
                        ] },
          'Sheet2' => { data_extraction_method: 'dynamic_fee_cols_no_ranges',
                        rows_data: [
                          { abc: 'Test', row_nr: 2 }
                        ] } }
      end
    end
  end
end
