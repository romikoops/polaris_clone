# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Dashboard::ModeOfTransportShare, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_user) }
  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }
  let(:result) do
    described_class.data(user: user, organization: organization, start_date: start_date, end_date: end_date)
  end

  before do
    Organizations.current_id = organization.id
    FactoryBot.create_list(:journey_query,
      2,
      client: client,
      organization: organization,
      result_count: 1)
  end

  context "when a quote shop" do
    before { organization.scope.update(content: { closed_quotation_tool: true }) }

    describe "data" do
      it "returns an array of mot shares for the period" do
        expect(result).to eq([{ count: 2, label: "ocean" }])
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

    describe "data" do
      it "returns an array of mot shares for the period" do
        expect(result).to eq([{ count: 2, label: "ocean" }])
      end
    end
  end
end
