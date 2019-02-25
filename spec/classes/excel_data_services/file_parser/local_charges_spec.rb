# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::FileParser::LocalCharges do
  before(:all) { @path_to_files = file_fixture('excel') }
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, file_or_path: file_or_path } }

  describe '.parse' do
    context 'with correct data sheet' do
      let(:file_or_path) do
        @path_to_files.join('local_charges', 'correct', 'one_col_fee_and_ranges_NO-RANGES-USED.xlsx')
      end
      let(:correctly_parsed_data) { build(:excel_data_parsed_correct_local_charges) }

      it 'returns successfully' do
        expect(described_class.parse(options)).to eq(correctly_parsed_data)
      end
    end

    context 'with faulty data sheet' do
      pending
    end
  end
end
