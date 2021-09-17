# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Dashboard::BookingsPerDay, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization, scope: scope) }
  let(:scope) { FactoryBot.build(:organizations_scope, content: scope_content) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:clients) { FactoryBot.create_list(:users_client, 2, organization: organization) }
  let(:start_date) { DateTime.new(2020, 2, 10) }
  let(:end_date) { DateTime.new(2020, 3, 10) }
  let(:shipment_date) { Date.new(2020, 2, 20) }
  let(:result) do
    described_class.data(user: user, organization: organization, start_date: start_date, end_date: end_date)
  end

  before do
    Organizations.current_id = organization.id
    FactoryBot.create_list(:journey_query,
      2,
      client: clients.first,
      organization: organization,
      result_count: 1,
      created_at: shipment_date)
    clients.map do |client|
      FactoryBot.create_list(:journey_query,
        2,
        client: client,
        organization: organization,
        result_count: 1)
    end
  end

  context "when a quote shop" do
    let(:scope_content) { { closed_quotation_tool: true } }

    describe ".data" do
      it "returns a count of requests and their date times" do
        expect(result).to eq([{ count: 2, label: shipment_date }])
      end
    end
  end

  context "when a booking shop" do
    before do
      Journey::Result.find_each do |result|
        FactoryBot.create(:journey_shipment_request,
          client_id: result.query.client_id,
          result: result,
          created_at: result.query.created_at)
      end
    end

    let(:scope_content) { { closed_quotation_tool: false, open_quotation_tool: false } }

    describe ".data" do
      it "returns a count of requests and their date times" do
        expect(result).to eq([{ count: 2, label: shipment_date }])
      end
    end
  end
end
