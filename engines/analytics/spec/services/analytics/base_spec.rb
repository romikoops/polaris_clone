# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Base, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:mots) { %w[air ocean] }
  let(:clients) { FactoryBot.create_list(:organizations_user, 2, organization: organization) }
  let(:blacklisted_client) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:start_date) { 1.month.ago }
  let(:end_date) { Time.zone.now }
  let(:service) {
    described_class.new(user: user, organization: organization, start_date: start_date, end_date: end_date)
  }
  let(:itineraries) do
    mots.map do |mot|
      FactoryBot.create(:gothenburg_shanghai_itinerary, mode_of_transport: mot, organization: organization)
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
  let!(:blacklisted_request) do
    itineraries.product([blacklisted_client]).map do |itinerary, client|
      FactoryBot.create(:legacy_shipment,
        itinerary: itinerary,
        user: client,
        organization: organization,
        with_breakdown: true,
        with_tenders: true)
    end
  end

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_scope,
      target: organization,
      content: {blacklisted_emails: [blacklisted_client.email]})
  end

  describe "quotations" do
    it "returns all the quotations made in the period" do
      expect(service.quotations.count).to eq(requests.length)
    end
  end

  describe "tenders" do
    it "returns all the tenders made in the period" do
      expect(service.tenders.count).to eq(requests.length)
    end
  end

  describe "itineraries" do
    it "returns all the itineraries made in the period" do
      expect(service.itineraries.count).to eq(itineraries.length)
    end
  end

  describe "clients" do
    before do
      ::Organizations.current_id = organization.id
    end

    it "returns all the clients made in the period" do
      aggregate_failures do
        expect(service.clients.count).to eq(3)
        expect(service.clients.first).to be_a(Organizations::User)
      end
    end
  end

  context "when a quote shop" do
    before do
      Organizations::Scope.find_by(target: organization)
        .update(content: {closed_quotation_tool: true, blacklisted_emails: [blacklisted_client.email]})
    end

    describe "tender_or_request" do
      it "returns a collection of tenders" do
        aggregate_failures do
          expect(service.tender_or_request.count).to eq(requests.length)
          expect(service.tender_or_request.first).to be_a(Quotations::Tender)
        end
      end
    end
  end

  context "when a booking shop" do
    before do
      Quotations::Tender.find_each do |tender|
        ::Organizations.current_id = organization.id
        FactoryBot.create(
          :shipments_shipment_request, user: tender.quotation.user, organization: organization, tender: tender
        )
      end
    end

    describe "tender_or_request" do
      it "returns a collection of tenders" do
        aggregate_failures do
          expect(service.tender_or_request.count).to eq(requests.length)
          expect(service.tender_or_request.first).to be_a(Shipments::ShipmentRequest)
        end
      end
    end
  end
end
