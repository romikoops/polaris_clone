# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Restructurers::PricingDynamicFeeColsNoRanges do
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, data: input_data } }

  describe '.restructure' do
    let(:input_data) { build(:excel_data_parsed_correct_pricings_dynamic_fee_cols_no_ranges).first }
    let(:output_data) { { 'Pricing' => build(:excel_data_restructured_correct_pricings_dynamic_fee_cols_no_ranges) } }
    let!(:result) { described_class.restructure(options) }

    it 'restructures the data correctly' do
      expect(result['Pricing']).to match_array(output_data['Pricing'])
    end

    context 'when rate_basis is lower_case' do
      let(:input_data) { build(:excel_data_parsed_lowcase_ratebasis_pricings_dynamic_fee_cols_no_ranges).first }

      it 'forces uppercase for rate_basis and restructures correctly' do
        expect(result['Pricing'].first).to match_array(output_data['Pricing'].first)
      end
    end
  end

  describe '.restructure with remarks' do
    let(:input_data) { build(:excel_data_parsed_correct_pricings_dynamic_fee_cols_no_ranges_with_remarks).first }
    let(:output_data) {
      { 'Pricing' =>
     build(:excel_data_restructured_correct_pricings_dynamic_fee_cols_no_ranges_with_remarks)}
    }
    let!(:result) { described_class.restructure(options) }

    it 'restructures the data correctly' do
      expect(result['Pricing'].first).to match_array(output_data['Pricing'].first)
    end
  end
end
