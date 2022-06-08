# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Base, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:company) { FactoryBot.create(:companies_company, organization: organization) }
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
        company: company,
        organization: organization,
        result_count: 1)
    end
  end

  before do
    FactoryBot.create_list(:journey_query,
      2,
      client: blacklisted_client,
      creator: blacklisted_client,
      company: company,
      organization: organization,
      result_count: 1)
    ::Organizations.current_id = organization.id
    organization.scope.update(content: { blacklisted_emails: [blacklisted_client.email] })
  end

  describe "#queries" do
    it "returns all the Queries made in the period scoped by organization" do
      expect(service.queries.count).to eq(requests.length)
    end

    context "when the Queries was made by a Guest User" do
      let(:clients) { [nil] }
      let(:company) { nil }

      it "returns all the queries made in the period including those made by guest users" do
        expect(service.queries.count).to eq(requests.length)
      end
    end

    context "when the Queries was made by a User with no company" do
      let(:clients) { [nil] }
      let(:company) { nil }

      it "returns all the queries made in the period including those without a company" do
        expect(service.queries.count).to eq(requests.length)
      end
    end
  end

  describe "#results" do
    it "returns all the Results made in the period" do
      expect(service.results.count).to eq(requests.length)
    end
  end

  describe "#clients" do
    before do
      ::Organizations.current_id = organization.id
    end

    it "returns all the clients active in the period", :aggregate_failures do
      expect(service.clients.count).to eq(3)
      expect(service.clients.first).to be_a(Users::Client)
    end
  end

  context "when a quote shop" do
    describe "#result_or_request" do
      it "returns a collection of results", :aggregate_failures do
        expect(service.result_or_request.count).to eq(requests.length)
        expect(service.result_or_request.first).to be_a(Journey::Result)
      end
    end

    describe "#requests_with_profiles" do
      it "returns a collection of quotes with the Users::Client joined in", :aggregate_failures do
        expect(service.requests_with_profiles.count).to eq(requests.length)
        expect(service.requests_with_profiles.pluck("users_clients.id").uniq).to eq(clients.pluck(:id))
      end
    end

    describe "#requests_with_companies" do
      it "returns a collection of quotes with the Companies::Company joined in", :aggregate_failures do
        expect(service.requests_with_companies.count).to eq(requests.length)
        expect(service.requests_with_companies.pluck("companies_companies.id").uniq).to eq([company.id])
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

    describe "#result_or_request" do
      it "returns a collection of bookings", :aggregate_failures do
        expect(service.result_or_request.count).to eq(requests.length)
        expect(service.result_or_request.first).to be_a(Journey::ShipmentRequest)
      end
    end

    describe "#requests_with_profiles" do
      it "returns a collection of bookings with the Users::Client joined in", :aggregate_failures do
        expect(service.requests_with_profiles.count).to eq(requests.length)
        expect(service.requests_with_profiles.pluck("users_clients.id").uniq).to match_array(clients.pluck(:id))
      end
    end

    describe "#requests_with_companies" do
      it "returns a collection of bookings with the Companies::Company joined in", :aggregate_failures do
        expect(service.requests_with_companies.count).to eq(requests.length)
        expect(service.requests_with_companies.pluck("companies_companies.id").uniq).to eq([company.id])
      end
    end
  end
end
