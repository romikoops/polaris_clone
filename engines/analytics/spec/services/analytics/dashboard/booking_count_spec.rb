# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analytics::Dashboard::BookingCount, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:clients) { FactoryBot.create_list(:organizations_user, 2, organization: organization) }
  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }
  let(:result) { described_class.data(user: user, organization: organization, start_date: start_date, end_date: end_date) }
  let(:itineraries) do
    itin_syms = %i[gothenburg_shanghai_itinerary shanghai_gothenburg_itinerary]
    itin_syms.map do |sym|
      FactoryBot.create(sym, organization: organization)
    end
  end
  let!(:requests) do
    itineraries.product(clients).map do |itinerary, client|
      FactoryBot.create(:legacy_shipment,
                        itinerary: itinerary,
                        user: client,
                        organization: organization,
                        with_breakdown: true,
                        with_tenders: true)
    end
  end

  before do
    Organizations.current_id = organization.id
    client = clients.first
    itineraries.map do |itinerary|
      FactoryBot.create(:legacy_shipment,
                        itinerary: itinerary,
                        user: client,
                        organization: organization,
                        created_at: Time.zone.now - 2.months,
                        with_breakdown: true,
                        with_tenders: true)
    end
  end

  context 'when a quote shop' do
    before { FactoryBot.create(:organizations_scope, target: organization, content: { closed_quotation_tool: true }) }

    describe '.data' do
      it 'returns a the quotation copunt for the time period' do
        expect(result).to eq(requests.length)
      end
    end
  end

  context 'when a booking shop' do
    before do
      Quotations::Tender.find_each do |tender|
        FactoryBot.create(:shipments_shipment_request,
                          user: user,
                          organization: organization,
                          tender: tender,
                          created_at: tender.quotation.created_at)
      end
    end

    describe '.data' do
      it 'returns a collection of tenders' do
        expect(result).to eq(requests.length)
      end
    end
  end
end
