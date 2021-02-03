# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Dashboard::BookingsPerDay, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:clients) { FactoryBot.create_list(:users_client, 2, organization: organization) }
  let(:start_date) { DateTime.new(2020, 2, 10) }
  let(:end_date) { DateTime.new(2020, 3, 10) }
  let(:shipment_date) { Date.new(2020, 2, 20) }
  let(:result) {
    described_class.data(user: user, organization: organization, start_date: start_date, end_date: end_date)
  }
  let(:itineraries) do
    itin_syms = %i[gothenburg_shanghai_itinerary shanghai_gothenburg_itinerary]
    itin_syms.map do |sym|
      FactoryBot.create(sym, organization: organization)
    end
  end

  before do
    Organizations.current_id = organization.id
    itineraries.product(clients).map do |itinerary, client|
      FactoryBot.create(:legacy_shipment,
        itinerary: itinerary,
        user: client,
        organization: organization,
        with_breakdown: true,
        with_tenders: true)
    end
    client = clients.first
    itineraries.map do |itinerary|
      FactoryBot.create(:legacy_shipment,
        itinerary: itinerary,
        user: client,
        organization: organization,
        created_at: shipment_date,
        with_breakdown: true,
        with_tenders: true)
    end
  end

  context "when a quote shop" do
    before { organization.scope.update(content: {closed_quotation_tool: true}) }

    describe ".data" do
      it "returns a count of requests and their date times" do
        expect(result).to eq([{count: 2, label: shipment_date}])
      end
    end
  end

  context "when a booking shop" do
    before do
      Quotations::Tender.find_each do |tender|
        ::Organizations.current_id = organization.id
        FactoryBot.create(:shipments_shipment_request,
          user: tender.quotation.user,
          organization: organization,
          tender: tender,
          created_at: tender.quotation.created_at)
      end
    end

    describe ".data" do
      it "returns a count of requests and their date times" do
        expect(result).to eq([{count: 2, label: shipment_date}])
      end
    end
  end
end
