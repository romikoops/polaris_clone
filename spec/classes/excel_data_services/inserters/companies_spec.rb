# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::Companies do
  let(:tenant) { FactoryBot.create(:tenant) }
  let(:options) { { tenant: tenant, data: input_data, options: {} } }
  let(:address) { create(:gothenburg_address) }
  let(:input_data) do
    [{
      name: 'Test Company',
      email: 'test@company.com',
      phone: '1234567879',
      vat_number: '987654321',
      external_id: 'abcde',
      address_id: address.id
    }]
  end

  describe '.insert' do
    it 'inserts correctly and returns correct stats' do
      stats = described_class.insert(options)
      expect(stats[:'tenants/companies'][:number_created]).to eq(1)
    end
  end
end
