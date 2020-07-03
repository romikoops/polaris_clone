# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Federation::Members do
  describe '#list' do
    context 'when returning the federated tenants' do
      let(:organization) { FactoryBot.build(:organizations_organization) }

      it 'returns the correct hierarchy' do
        expect(described_class.new(organization: organization).list).to eq([])
      end
    end
  end
end
