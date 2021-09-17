# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::Dashboard::MostActiveCarriers, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_user) }
  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }
  let(:result) do
    described_class.data(user: user, organization: organization, start_date: start_date, end_date: end_date)
  end
  let(:query) do
    FactoryBot.create(:journey_query,
      client: client,
      organization: organization,
      result_count: 1)
  end

  before do
    Organizations.current_id = organization.id
    FactoryBot.create(:journey_result,
      query: query,
      route_sections: [
        FactoryBot.build(:journey_route_section, mode_of_transport: "ocean", carrier: "Maersk")
      ])
    FactoryBot.create(:journey_result, query: query)
  end

  describe "data" do
    it "returns an array of most active carriers for the period" do
      expect(result).to eq([{ count: 2, label: "MSC" }, { count: 1, label: "Maersk" }])
    end
  end
end
