# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Dashboard::AverageBookingValue, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }
  let(:result) {
    described_class.data(user: user, organization: organization, start_date: start_date, end_date: end_date)
  }

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create_list(:legacy_shipment,
      2,
      user: user,
      organization: organization,
      with_breakdown: true,
      with_tenders: true)
  end

  context "when a quote shop" do
    before { organization.scope.update(content: {closed_quotation_tool: true}) }

    describe "data" do
      it "returns an object with average booking values" do
        expect(result).to eq(symbol: "EUR", value: 0.999e1)
      end
    end
  end

  context "when a booking shop" do
    before do
      Quotations::Tender.find_each do |tender|
        FactoryBot.create(:shipments_shipment_request,
          user: user,
          organization: organization,
          tender: tender,
          created_at: tender.quotation.created_at)
      end
    end

    describe "data" do
      it "returns an object with average booking values" do
        expect(result).to eq(symbol: "EUR",
                             value: 0.999e1)
      end
    end
  end
end
