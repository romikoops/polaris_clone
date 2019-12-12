# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Federation::Members do
  describe '#list' do
    context 'when returning the federated tenants' do
      let(:tenant) { FactoryBot.build(:tenants_tenant) }

      it 'returns the correct hierarchy' do
        expect(described_class.new(tenant: tenant).list).to eq([])
      end
    end
  end
end
