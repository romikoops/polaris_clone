# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Validators::SmartAssumptions::Base do
  let(:organization) { create(:organizations_organization) }
  let(:data) { [[nil]] }
  let(:options) { { organization: organization, sheet_name: 'Sheet1', data: data } }

  describe '.perform' do
    it 'raises a NotImplementedError' do
      validator = described_class.new(options)
      expect { validator.perform }.to raise_error(NotImplementedError)
    end
  end
end
