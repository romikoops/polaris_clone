# frozen_string_literal: true

require 'rails_helper'
require 'timecop'

module AdmiraltyReports
  RSpec.describe StatsCreator::Quotations do
    let(:tenants) do
      [
        FactoryBot.create(:legacy_tenant, scope: { 'open_quotation_tool' => true }),
        FactoryBot.create(:legacy_tenant, scope: { 'open_quotation_tool' => false })
      ]
    end
    let(:users) do
      [
        FactoryBot.create(:legacy_user)
      ]
    end

    describe '#perform' do
      context 'quotation tool' do
        let(:tenant) { tenants.first }
        let!(:user) { users.first }
        let!(:shipment) do
          Timecop.freeze(DateTime.parse('01 Apr 2019 12:00')) do
            FactoryBot.create(:legacy_shipment, tenant_id: tenant.id, user_id: user.id)
          end
        end
        let!(:quotation) do
          Timecop.freeze(DateTime.parse('01 Apr 2019 12:05')) do
            FactoryBot.create(:legacy_quotation, user_id: user.id, original_shipment_id: shipment.id)
          end
        end

        it 'returns the correct stats' do
          expect(described_class.new(tenant).perform).to eq(
            '04/01/2019' => {
              combined_data: { avg_time_for_booking_process: '5 minutes', n_individual_agents: 1, n_quotations: 1 },
              data_per_agent: [{ count: 1, email: 'demo1@itsmycargo.test' }]
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
