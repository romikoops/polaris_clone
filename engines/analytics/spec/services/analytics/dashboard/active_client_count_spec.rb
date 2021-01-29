# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Dashboard::ActiveClientCount, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let!(:clients) { FactoryBot.create_list(:users_client, 2, organization: organization, last_login_at: Time.zone.now) }
  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }

  let(:result) {
    described_class.data(user: user, organization: organization, start_date: start_date, end_date: end_date)
  }

  before do
    ::Organizations.current_id = organization.id
  end

  context "with two active clients" do
    describe ".data" do
      it "returns a the clients count for the time period" do
        expect(result).to eq(clients.length)
      end
    end
  end
end
