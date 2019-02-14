# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/file_parser'

RSpec.describe ExcelDataServices::FileParser::Pricing do
  before(:all) { @path_to_files = file_fixture('excel') }
  let(:tenant) { create(:tenant) }

  describe '.parse' do
    context 'with correct data sheet' do
      include_examples 'parse excel sheet successfully' do
        let(:file_or_path) do
          @path_to_files.join('pricings', 'correct', 'one_col_fee_and_ranges_NO-RANGES-USED.xlsx')
        end
        let(:correctly_parsed_data) { build(:excel_data_parsed_correct_pricings) }
      end
    end

    context 'with faulty data sheet' do
      pending
    end
  end
end
