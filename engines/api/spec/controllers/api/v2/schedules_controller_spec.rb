# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::SchedulesController, type: :controller do
    routes { Engine.routes }

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:query) { FactoryBot.create(:journey_query, organization: organization) }
    let(:result) { FactoryBot.create(:journey_result, query: query) }
    let(:decorated_result) { Api::V2::ResultDecorator.new(result) }
    let(:origin) { decorated_result.origin_route_point.locode }
    let(:destination) { decorated_result.destination_route_point.locode }
    let(:carrier) { decorated_result.carrier }
    let(:service) { decorated_result.service_level }
    let(:closing_date) { Time.zone.tomorrow }
    let(:origin_departure) { closing_date }
    let(:destination_arrival) { origin_departure + 3.weeks }
    let(:params) { { result_id: result.id, organization_id: organization.id } }
    let!(:schedules_schedule) do
      FactoryBot.create(:schedules_schedule,
        organization: organization,
        origin: origin,
        destination: destination,
        carrier: carrier,
        service: service,
        origin_departure: origin_departure,
        destination_arrival: destination_arrival,
        closing_date: closing_date)
    end

    before do
      request.headers["Authorization"] = token_header
    end

    describe "GET #index" do
      context "with valid schedules" do
        it "successfully returns the schedules for the given Result" do
          get :index, params: params, as: :json
          expect(response_data.pluck("id")).to match_array([schedules_schedule.id])
        end
      end

      context "with expired schedules" do
        let(:closing_date) { Time.zone.yesterday }

        it "does not return the schedules which are expired" do
          get :index, params: params, as: :json
          expect(response_data.pluck("id")).not_to include([schedules_schedule.id])
        end
      end

      context "when schedule belong to a different carrier" do
        let(:carrier) { "test carrier" }

        it "does not return the schedules which does not belong to the carrier" do
          get :index, params: params, as: :json
          expect(response_data.pluck("id")).not_to include([schedules_schedule.id])
        end
      end

      context "when schedule belong to a different service level" do
        let(:service) { "cheapest" }

        it "does not return the schedules which has different service level" do
          get :index, params: params, as: :json
          expect(response_data.pluck("id")).not_to include([schedules_schedule.id])
        end
      end
    end

    describe "GET #show" do
      let(:params) { { result_id: result.id, organization_id: organization.id, id: schedules_schedule.id } }

      context "with valid schedule" do
        it "successfully returns the schedules for the given result and schedule" do
          get :show, params: params, as: :json
          expect(response_data["id"]).to eq(schedules_schedule.id)
        end
      end
    end
  end
end
