# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Restructurers::Margins do
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, data: input_data } }

  describe '.restructure' do
    let(:input_data) { build(:excel_data_parsed_correct_margins).first }
    let(:output_data) { { 'Margins' => build(:excel_data_restructured_correct_margins) } }

    it 'restructures the data correctly' do
      expect(described_class.restructure(options)).to eq(output_data)
    end
  end
end
