# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DataValidators::SmartAssumptions::Base do
  let(:tenant) { create(:tenant) }
  let(:data) { [[nil]] }
  let(:options) { { tenant: tenant, data: data } }

  describe '.perform' do
    it 'raises a NotImplementedError' do
      validator = described_class.new(options)
      expect { validator.perform }.to raise_error(NotImplementedError)
    end
  end
end
