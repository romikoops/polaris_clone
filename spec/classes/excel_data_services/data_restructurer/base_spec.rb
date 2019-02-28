# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DataRestructurer::Base do
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, data: data, klass_identifier: klass_identifier } }

  describe '.restructure_data' do
    let(:data) { build(:excel_data_parsed) }
    let(:klass_identifier) {}

    it 'passes the data on without restructuring' do
      expect(described_class.restructure_data(options)).to eq(data)
    end
  end
end
