# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Base, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:mots) { %w[air ocean] }
  let(:clients) { FactoryBot.create_list(:users_client, 2, organization: organization) }
  let(:blacklisted_client) { FactoryBot.create(:users_client, organization: organization) }
  let(:start_date) { 1.month.ago }
  let(:end_date) { Time.zone.now }
  let(:service) do
    described_class.new(user: user, organization: organization, start_date: start_date, end_date: end_date)
  end
  let!(:requests) do
    clients.flat_map do |client|
      FactoryBot.create_list(:journey_query,
        2,
        client: client,
        creator: client,
        organization: organization,
        result_set_count: 1)
    end
  end

  before do
    FactoryBot.create_list(:journey_query,
      2,
      client: blacklisted_client,
      creator: blacklisted_client,
      organization: organization,
      result_set_count: 1)
    ::Organizations.current_id = organization.id
    organization.scope.update(content: { blacklisted_emails: [blacklisted_client.email] })
  end

  describe "queries" do
    it "returns all the queries made in the period" do
      expect(service.queries.count).to eq(requests.length)
    end
  end

  describe "results" do
    it "returns all the results made in the period" do
      expect(service.results.count).to eq(requests.length)
    end
  end

  describe "clients" do
    before do
      ::Organizations.current_id = organization.id
    end

    it "returns all the clients made in the period", :aggregate_failures do
      expect(service.clients.count).to eq(3)
      expect(service.clients.first).to be_a(Users::Client)
    end
  end

  context "when a quote shop" do
    describe "result_or_request" do
      it "returns a collection of results" do
        aggregate_failures do
          expect(service.result_or_request.count).to eq(requests.length)
          expect(service.result_or_request.first).to be_a(Journey::Result)
        end
      end
    end
  end

  context "when a booking shop" do
    before do
      Organizations::Scope.find_by(target: organization)
        .update(content: { closed_quotation_tool: false, open_quotation_tool: false, blacklisted_emails: [blacklisted_client.email] })
      Journey::Result.find_each do |result|
        FactoryBot.create(:journey_shipment_request,
          client_id: result.query.client_id,
          result: result,
          created_at: result.created_at)
      end
    end

    describe "result_or_request" do
      it "returns a collection of tenders" do
        aggregate_failures do
          expect(service.result_or_request.count).to eq(requests.length)
          expect(service.result_or_request.first).to be_a(Journey::ShipmentRequest)
        end
      end
    end
  end
end
