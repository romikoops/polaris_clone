# frozen_string_literal: true

require 'rails_helper'

module AdmiraltyReports
  RSpec.describe StatsCreator::Quotations do
    let(:tenants) do
      [
        Tenant.create(scope: { 'open_quotation_tool' => true }),
        Tenant.create(scope: { 'open_quotation_tool' => false })
      ]
    end
    let(:users) do
      [
        User.create(tenant: tenants.first, email: 'user1@example.com')
      ]
    end

    describe '#perform' do
      context 'quotation tool' do
        it 'returns the correct stats' # pending
      end

      context 'booking tool' do
        let(:tenant) { tenants.second }

        it 'returns the correct stats' # pending
      end
    end
  end
end
