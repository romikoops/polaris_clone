# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe DashboardService, type: :service do
    let(:quote_organization) { FactoryBot.create(:organizations_organization) }
    let(:quote_user) { FactoryBot.create(:users_client, organization_id: quote_organization.id) }
    let(:start_date) { DateTime.new(2020, 2, 10) }
    let(:end_date) { DateTime.new(2020, 3, 10) }

    describe "with activeClientCount widget" do
      let(:widget_class) { Analytics::Dashboard::ActiveClientCount }
      let(:widget) do
        widget_class.new(organization: quote_organization, user: quote_user, start_date: start_date, end_date: end_date)
      end
      let(:mock_result) { 1 }
      let(:result) do
        described_class.data(
          user: quote_user, organization: quote_organization,
          widget_name: "activeClientCount", start_date: start_date, end_date: end_date
        )
      end

      before do
        allow(widget_class).to receive(:new).and_return(widget)
        allow(widget).to receive(:data).and_return(mock_result)
      end

      it "instantiates the correct widget class and calls the service" do
        expect(result).to eq(mock_result)
      end
    end
  end
end
