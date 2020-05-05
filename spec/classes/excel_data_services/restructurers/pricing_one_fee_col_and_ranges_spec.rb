# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Restructurers::PricingOneFeeColAndRanges do
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, data: input_data } }

  describe '.restructure' do
    let(:input_data) { build(:excel_data_parsed_correct_pricings_one_fee_col_and_ranges).first }
    let(:output_data) { { 'Pricing' => build(:excel_data_restructured_correct_pricings_one_fee_col_and_ranges) } }
    let(:result) { described_class.restructure(options) }

    it 'restructures the data correctly' do
      expect(result['Pricing']).to match_array(output_data['Pricing'])
    end
  end
end
