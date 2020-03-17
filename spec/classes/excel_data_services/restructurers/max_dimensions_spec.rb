# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Restructurers::MaxDimensions do
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, data: input_data } }

  describe '.restructure' do
    let(:input_data) { build(:excel_data_parsed_correct_max_dimensions).first }
    let(:output_data) { { 'MaxDimensions' => build(:excel_data_restructured_max_dimensions) } }

    it 'restructures the data correctly' do
      expect(described_class.restructure(options)).to eq(output_data)
    end
  end
end
