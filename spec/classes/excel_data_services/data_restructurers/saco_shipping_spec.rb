# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DataRestructurers::SacoShipping do
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, data: input_data } }

  describe '.restructure' do
    let(:input_data) { build(:excel_data_parsed_correct_saco_shipping).first }
    let(:output_data_pricings) { { 'Pricing' => build(:excel_data_restructured_correct_saco_shipping_pricings) } }
    let(:output_data_local_charges) { { 'LocalCharges' => build(:excel_data_restructured_correct_saco_shipping_local_charges) } }

    it 'restructures the data correctly' do
      result = described_class.restructure(options)
      expect(result.slice('Pricing')).to eq(output_data_pricings)
      expect(result.slice('LocalCharges')).to eq(output_data_local_charges)
    end
  end
end
