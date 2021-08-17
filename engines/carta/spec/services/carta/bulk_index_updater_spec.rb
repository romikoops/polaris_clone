# frozen_string_literal: true

require "rails_helper"

module Carta
  RSpec.describe BulkIndexUpdater do
    let!(:route_points_in_range) { FactoryBot.create_list(:journey_route_point, 5, created_at: 1.day.ago) }
    let(:expected_data) { { doc_ids: route_points_in_range.pluck(:geo_id) } }
    let(:stubs) { Faraday::Adapter::Test::Stubs.new }
    let(:connection) { Faraday.new { |stubbed_connection| stubbed_connection.adapter(:test, stubs) } }

    before do
      FactoryBot.create(:journey_route_point, locode: nil, created_at: 1.day.ago)
      FactoryBot.create(:journey_route_point, created_at: 5.days.ago)
      allow(described_class).to receive(:connection).and_return(connection)
    end

    describe ".perform" do
      context "when carta responds with 200" do
        before do
          stubs.post("/v1/locations/counters/increment", expected_data) do
            [
              200,
              { 'Content-Type': "application/json" }
            ]
          end
          described_class.perform
        end

        it "calls the carta /counters/increment endpoint with the argument id as a param", :aggregate_failures do
          stubs.verify_stubbed_calls
        end
      end

      context "when carta responds with 503" do
        before do
          stubs.post("/v1/locations/counters/increment", expected_data) do
            [
              503,
              { 'Content-Type': "application/json" }
            ]
          end
        end

        it "calls the carta /counters/increment endpoint with the argument id as a param", :aggregate_failures do
          expect { described_class.perform }.to raise_error(Carta::BulkIndexUpdater::CartaBulkUpdateFailed)
          stubs.verify_stubbed_calls
        end
      end

      context "when carta responds with 401" do
        before do
          stubs.post("/v1/locations/counters/increment") do
            [
              401,
              { 'Content-Type': "application/json" }
            ]
          end
        end

        it "calls the carta /counters/increment endpoint with the argument id as a param", :aggregate_failures do
          expect { described_class.perform }.to raise_error(Carta::BulkIndexUpdater::CartaBulkUpdateFailed)
          stubs.verify_stubbed_calls
        end
      end
    end
  end
end
