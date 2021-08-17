# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Dashboard::BookingsPerCompany, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_user) }
  let(:company) { FactoryBot.create(:companies_company, organization: organization, name: "Company Name") }
  let(:clients) { FactoryBot.create_list(:users_client, 2, organization: organization) }
  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }
  let(:result) do
    described_class.data(user: user, organization: organization, start_date: start_date, end_date: end_date)
  end

  before do
    Organizations.current_id = organization.id
    clients.each do |client|
      FactoryBot.create(:companies_membership, company: company, client: client)
    end
    FactoryBot.create_list(:journey_query,
      2,
      client: clients.first,
      organization: organization,
      result_set_count: 1,
      created_at: Time.zone.now - 2.months)
    clients.map do |client|
      FactoryBot.create_list(:journey_query,
        2,
        client: client,
        organization: organization,
        result_set_count: 1)
    end
  end

  context "when a quote shop" do
    before { organization.scope.update(content: { closed_quotation_tool: true }) }

    describe ".data" do
      it "returns a the company count for the time period" do
        expect(result).to eq([{ count: 4, label: "Company Name" }])
      end
    end
  end

  context "when a booking shop" do
    before do
      Journey::Result.find_each do |result|
        FactoryBot.create(:journey_shipment_request,
          client_id: result.query.client_id,
          result: result,
          created_at: result.created_at)
      end
    end

    describe ".data" do
      it "returns a the company count for the time period" do
        expect(result).to eq([{ count: 4, label: "Company Name" }])
      end
    end
  end
end
