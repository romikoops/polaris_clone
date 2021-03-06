# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Dashboard::ActiveCompanyCount, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization, last_login_at: 2.days.ago) }
  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }
  let(:company) { FactoryBot.create(:companies_company, organization: organization) }
  let(:result) do
    described_class.data(user: user, organization: organization, start_date: start_date, end_date: end_date)
  end

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:companies_membership, company: company, client: user)
  end

  context "with one active company" do
    describe ".data" do
      it "returns the active company count for the time period" do
        expect(result).to eq(1)
      end
    end
  end
end
