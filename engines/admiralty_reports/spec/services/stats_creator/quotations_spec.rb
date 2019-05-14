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
        let(:tenant) { tenants.first }
        let!(:user) { users.first }
        let!(:shipment) do
          date_time = DateTime.parse('01 Apr 2019 12:00')
          Shipment.create(tenant_id: tenant.id, user_id: user.id, created_at: date_time, updated_at: date_time)
        end
        let!(:quotation) do
          date_time = DateTime.parse('01 Apr 2019 12:05')
          Quotation.create(user_id: user.id, original_shipment_id: shipment.id, created_at: date_time, updated_at: date_time)
        end

        it 'returns the correct stats' do
          expect(described_class.new(tenant).perform).to eq(
            '04/01/2019' => {
              combined_data: { avg_time_for_booking_process: '5 minutes', n_individual_agents: 1, n_quotations: 1 },
              data_per_agent: [{ count: 1, email: 'user1@example.com' }]
            }
          )
        end
      end

      context 'booking tool' do
        let(:tenant) { tenants.second }

        it 'returns the correct stats' # pending
      end
    end
  end
end
