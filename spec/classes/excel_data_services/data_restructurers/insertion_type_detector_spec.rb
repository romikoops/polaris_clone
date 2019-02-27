# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DataRestructurers::InsertionTypeDetector do
  describe '.detect' do
    let(:trigger_local_charges) { { fee_code: 'THC' } }
    let(:trigger_pricing) { { fee_code: 'OTHER' } }

    it 'detects the correct insertion type' do
      expect(described_class.detect(trigger_local_charges, 'saco_shipping')).to eq('LocalCharges')
      expect(described_class.detect(trigger_pricing, 'saco_shipping')).to eq('Pricing')
    end
  end
end
