# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Dashboard::BookingsPerUser, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_user) }
  let(:clients) { FactoryBot.create_list(:users_client, 2, organization: organization, last_login_at: Time.zone.now) }
  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }

  let(:result) do
    described_class.data(user: user, organization: organization, start_date: start_date, end_date: end_date)
  end
  let(:client_a) { clients.first }
  let(:client_b) { clients.last }
  let(:client_a_label) { [client_a.profile.first_name, client_a.profile.last_name].join(" ") }
  let(:client_b_label) { [client_b.profile.first_name, client_b.profile.last_name].join(" ") }

  before do
    Organizations.current_id = organization.id
    FactoryBot.create_list(:journey_query,
      2,
      client: client_a,
      organization: organization,
      result_set_count: 1)
    FactoryBot.create(:journey_query,
      client: client_b,
      organization: organization,
      result_set_count: 1)
    FactoryBot.create(:journey_query,
      client: client_b,
      organization: organization,
      created_at: Time.zone.now - 2.months,
      result_set_count: 1)
  end

  context "when a quote shop" do
    before { organization.scope.update(content: { closed_quotation_tool: true }) }

    describe "data" do
      it "returns an array of bookings per user for the period" do
        expect(result).to eq([{ count: 2, label: client_a_label }, { count: 1, label: client_b_label }])
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
      it "returns an array of bookings per user for the period" do
        expect(result).to eq([{ count: 2, label: client_a_label }, { count: 1, label: client_b_label }])
      end
    end
  end
end
