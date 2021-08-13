# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::SchedulesController, type: :controller do
    routes { Engine.routes }

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:result) { FactoryBot.create(:journey_result) }
    let(:params) { { result_id: result.id, organization_id: organization.id } }

    before do
      request.headers["Authorization"] = token_header
    end

    describe "GET #index" do
      schedule_attributes = { id: "96b0a57c-d9ae-453f-b56f-3b154eb10cda",
                              vessel_no: "1234",
                              voyage_code: "0000",
                              estimated_arrival_time: DateTime.now,
                              estimated_departure_time: 10.days.from_now,
                              closing_date: 7.days.from_now }
      before do
        allow(controller).to receive(:schedules).and_return(
          [instance_double("Schedule", schedule_attributes)]
        )
      end

      it "successfully returns the Result ids for the given ResultSet" do
        get :index, params: params, as: :json
        # TODO: Implement a Journey::Schedule factory and used to match array
        expect(response_data.pluck("id")).to match_array([schedule_attributes[:id]])
      end
    end
  end
end
