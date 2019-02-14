# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DataRestructurer::Pricing do
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, data: input_data, klass_identifier: klass_identifier } }

  describe '.restructure_data' do
    let(:input_data) { build(:excel_data_parsed_correct_pricings) }
    let(:klass_identifier) { 'Pricing' }
    let(:output_data) { build(:excel_data_restructured_correct_pricings) }

    it 'restructures the data correctly' do
      expect(described_class.restructure_data(options)).to eq(output_data)
    end
  end
end
