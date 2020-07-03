# frozen_string_literal: true

require 'rails_helper'
module AdmiraltyReports
  RSpec.describe Stats, type: :model do
    let!(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:user) { FactoryBot.create(:organizations_user, email: 'test@test.com', organization: organization) }
    let(:created_date) { DateTime.new(2020, 2, 1) }
    let(:updated_date) { DateTime.new(2020, 2, 3) }
    let(:legacy_quotations_created_date) { DateTime.new(2019, 2, 2) }
    let(:legacy_quotations_updated_date) { DateTime.new(2019, 2, 3) }

    context 'when stat is created for quote shop' do
      before do
        ::Organizations.current_id = organization.id
        FactoryBot.create(:quotations_quotation, organization: organization, updated_at: updated_date, created_at: created_date, user: user)
        FactoryBot.create(:organizations_scope, target: organization, content: { open_quotation_tool: true })
        FactoryBot.create(:companies_company, :with_member, organization: organization, member: user)
      end

      let(:expected_stat) do
        { created_date => {
          combined_data: { avg_time_for_booking_process: '2 days',
                           n_individual_agents: 1,
                           n_shipments: 1 },
          data_per_agent: [{ company_name: nil,
                             count: 1,
                             email: 'test@test.com' }]
        } }
      end

      it 'returns a proper stat format for quotation quotations when overview is called' do
        result = described_class.new(organization: organization, year: 2020, month: 2).overview
        expect(result).to eq(expected_stat)
      end

      it 'returns an array of all quotation quotations requests when .raw_request_data is called' do
        raw_request_data = described_class.new(organization: organization, year: 2020, month: 2).raw_request_data
        expect(raw_request_data.first).to eq(Quotations::Quotation.first)
      end
    end

    context 'when stat is created for non-quote shop' do
      before do
        ::Organizations.current_id = organization.id
        FactoryBot.create(:legacy_shipment, user: user, organization: organization, updated_at: updated_date, created_at: created_date, status: 'confirmed')
        FactoryBot.create(:organizations_scope, target: organization, content: { open_quotation_tool: false })
        FactoryBot.create(:companies_company, :with_member, organization: organization, member: user)
      end

      let(:expected_stat) do
        { created_date => {
          combined_data: { avg_time_for_booking_process: '2 days',
                           n_individual_agents: 1,
                           n_shipments: 1 },
          data_per_agent: [{ company_name: nil,
                             count: 1,
                             email: 'test@test.com' }]
        } }
      end

      it 'returns a proper stat format for legacy shipments when overview is called' do
        result = described_class.new(organization: organization, year: 2020, month: 2).overview
        expect(result).to eq(expected_stat)
      end

      it 'returns an array of all legacy shipment requests when .raw_request_data is called' do
        raw_request_data = described_class.new(organization: organization, year: 2020, month: 2).raw_request_data
        expect(raw_request_data.first).to eq(Legacy::Shipment.first)
      end
    end

    context 'when stat is created for quote shop before quotation quotes' do
      before do
        ::Organizations.current_id = organization.id
        legacy_shipment = FactoryBot.create(:legacy_shipment, user: user, organization: organization, updated_at: legacy_quotations_updated_date, created_at: legacy_quotations_created_date, status: 'confirmed')
        FactoryBot.create(:legacy_quotation, user: user, updated_at: legacy_quotations_updated_date, created_at: legacy_quotations_created_date, original_shipment_id: legacy_shipment.id)
        FactoryBot.create(:organizations_scope, target: organization, content: { open_quotation_tool: true })
        FactoryBot.create(:companies_company, :with_member, organization: organization, member: user)
      end

      let(:expected_stat) do
        { legacy_quotations_created_date => {
          combined_data: { avg_time_for_booking_process: '1 day',
                           n_individual_agents: 1,
                           n_shipments: 1 },
          data_per_agent: [{ company_name: nil,
                             count: 1,
                             email: 'test@test.com' }]
        } }
      end

      it 'returns a proper stat format for legacy quotations when overview is called' do
        result = described_class.new(organization: organization, year: 2019, month: 2).overview
        expect(result).to eq(expected_stat)
      end

      it 'returns an array of all legacy quotations requests when .raw_request_data is called' do
        raw_request_data = described_class.new(organization: organization, year: 2019, month: 2).raw_request_data
        expect(raw_request_data.first).to eq(Legacy::Quotation.first)
      end
    end
  end
end
