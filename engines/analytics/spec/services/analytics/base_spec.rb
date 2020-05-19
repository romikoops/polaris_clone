# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analytics::Base, type: :service do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
  let(:admin_role) { FactoryBot.create(:legacy_role, name: 'admin') }
  let(:shipper_role) { FactoryBot.create(:legacy_role, name: 'shipper') }
  let(:legacy_user) { FactoryBot.create(:legacy_user, tenant: legacy_tenant, role: admin_role, with_profile: true) }
  let(:user) { Tenants::User.find_by(legacy_id: legacy_user.id) }
  let(:mots) { %w[air ocean] }
  let(:itineraries) do
    mots.map do |mot|
      FactoryBot.create(:gothenburg_shanghai_itinerary, mode_of_transport: mot, tenant: legacy_tenant)
    end
  end
  let(:clients) do
    FactoryBot.create_list(:legacy_user, 2, tenant: legacy_tenant, role: shipper_role, with_profile: true)
  end

  let(:blacklisted_client) { FactoryBot.create(:legacy_user, tenant: legacy_tenant, role: shipper_role, with_profile: true) }

  let!(:requests) do
    itineraries.product(clients).map do |itinerary, client|
      FactoryBot.create(:legacy_shipment,
                        itinerary: itinerary,
                        user: client,
                        tenant: legacy_tenant,
                        with_breakdown: true,
                        with_tenders: true)
    end
  end

  let!(:blacklisted_request) do
    itineraries.product([blacklisted_client]).map do |itinerary, client|
      FactoryBot.create(:legacy_shipment,
                        itinerary: itinerary,
                        user: client,
                        tenant: legacy_tenant,
                        with_breakdown: true,
                        with_tenders: true)
    end
  end

  let!(:tenants_scope) { Tenants::Scope.create(target: tenant, content: { blacklisted_emails: [blacklisted_client.email] }) }

  let(:start_date) { 1.month.ago }
  let(:end_date) { Time.zone.now }

  let(:service) { described_class.new(user: user, start_date: start_date, end_date: end_date) }

  describe 'quotations' do
    it 'returns all the quotations made in the period' do
      expect(service.quotations.count).to eq(requests.length)
    end
  end

  describe 'tenders' do
    it 'returns all the tenders made in the period' do
      expect(service.tenders.count).to eq(requests.length)
    end
  end

  describe 'itineraries' do
    it 'returns all the itineraries made in the period' do
      expect(service.itineraries.count).to eq(itineraries.length)
    end
  end

  describe 'clients' do
    it 'returns all the clients made in the period' do
      aggregate_failures do
        expect(service.clients.count).to eq(clients.length)
        expect(service.clients.first).to be_a(Tenants::User)
      end
    end
  end

  describe 'legacy_clients' do
    it 'returns all the legacy_clients made in the period' do
      aggregate_failures do
        expect(service.legacy_clients.count).to eq(clients.length)
        expect(service.legacy_clients.first).to be_a(Legacy::User)
      end
    end
  end

  context 'when a quote shop' do
    before { tenants_scope.update(content: { closed_quotation_tool: true, blacklisted_emails: [blacklisted_client.email] }) }

    describe 'tender_or_request' do
      it 'returns a collection of tenders' do
        aggregate_failures do
          expect(service.tender_or_request.count).to eq(requests.length)
          expect(service.tender_or_request.first).to be_a(Quotations::Tender)
        end
      end
    end
  end

  context 'when a booking shop' do
    before do
      Quotations::Tender.find_each do |tender|
        FactoryBot.create(:shipments_shipment_request, user: tender.quotation.tenants_user, tenant: tenant, tender: tender)
      end
    end

    describe 'tender_or_request' do
      it 'returns a collection of tenders' do
        aggregate_failures do
          expect(service.tender_or_request.count).to eq(requests.length)
          expect(service.tender_or_request.first).to be_a(Shipments::ShipmentRequest)
        end
      end
    end
  end
end
