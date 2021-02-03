# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Dashboard::ModeOfTransportShare, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:carrier_a) { FactoryBot.create(:legacy_carrier, name: "A", code: "a") }
  let(:carrier_b) { FactoryBot.create(:legacy_carrier, name: "B", code: "b") }
  let(:tenant_vehicle_a) {
    FactoryBot.create(:legacy_tenant_vehicle, name: "TV- A", carrier: carrier_a, organization: organization)
  }
  let(:tenant_vehicle_b) {
    FactoryBot.create(:legacy_tenant_vehicle, name: "TV-B", carrier: carrier_b, organization: organization)
  }
  let(:trip_a) { FactoryBot.create(:legacy_trip, tenant_vehicle: tenant_vehicle_a) }
  let(:trip_b) { FactoryBot.create(:legacy_trip, tenant_vehicle: tenant_vehicle_b) }
  let(:clients) { FactoryBot.create_list(:users_client, 2, organization: organization) }
  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }
  let(:result) {
    described_class.data(user: user, organization: organization, start_date: start_date, end_date: end_date)
  }

  before do
    Organizations.current_id = organization.id
    [
      FactoryBot.create(:legacy_shipment,
        trip: trip_a,
        user: clients.first,
        organization: organization,
        with_breakdown: true,
        with_tenders: true),
      FactoryBot.create(:legacy_shipment,
        trip: trip_a,
        user: clients.first,
        organization: organization,
        with_breakdown: true,
        with_tenders: true)
    ]
  end

  context "when a quote shop" do
    before { organization.scope.update(content: {closed_quotation_tool: true}) }

    describe "data" do
      it "returns an array of mot shares for the period" do
        expect(result).to eq([{count: 2, label: "ocean"}])
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

    describe "data" do
      it "returns an array of mot shares for the period" do
        expect(result).to eq([{count: 2, label: "ocean"}])
      end
    end
  end
end
