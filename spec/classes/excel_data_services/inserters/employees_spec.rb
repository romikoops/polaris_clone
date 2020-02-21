# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::Employees do
  let(:tenant) { FactoryBot.create(:tenant) }
  let(:options) { { tenant: tenant, data: input_data, options: {} } }
  let(:input_data) do
    [{
      first_name: 'Test',
      last_name: 'User',
      email: 'testuser@itsmycargo.com',
      password: 'password',
      phone: '123456789'
    }]
  end

  before { FactoryBot.create(:role) }

  describe '.insert' do
    it 'inserts correctly and returns correct stats' do
      stats = described_class.insert(options)
      expect(stats[:'tenants/users'][:number_created]).to eq(1)
    end
  end
end
