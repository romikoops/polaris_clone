# frozen_string_literal: true

require "rails_helper"

module Carta
  RSpec.describe BulkIndexUpdater do
    describe ".perform" do
      let(:stubs) { Faraday::Adapter::Test::Stubs.new }
      let(:connection) do
        Faraday.new do |stubbed_connection|
          stubbed_connection.adapter(
            :test,
            Faraday::Adapter::Test::Stubs.new do |stubs|
              stubs.post("/locations/counters/increment", expected_data) do
                response
              end
            end
          )
        end
      end
      let(:expected_data) { JSON.generate({ "doc_ids": ["IMC-GEOID"] }) }

      before do
        FactoryBot.create(:journey_route_point, geo_id: "IMC-GEOID", created_at: Time.zone.yesterday.middle_of_day)
        FactoryBot.create(:journey_route_point, locode: nil, created_at: Time.zone.yesterday.middle_of_day)
        FactoryBot.create(:journey_route_point, created_at: 5.days.ago)
      end

      context "when carta responds with 200" do
        let(:response) do
          [
            200,
            { 'Content-Type': "application/json" }
          ]
        end

        before do
          allow(described_class).to receive(:connection).and_return(connection)
          described_class.perform
        end

        it "calls the carta /counters/increment endpoint with the argument id as a param", :aggregate_failures do
          stubs.verify_stubbed_calls
        end
      end

      context "when carta responds with 503" do
        let(:response) do
          [
            503,
            { 'Content-Type': "application/json" }
          ]
        end

        before do
          allow(described_class).to receive(:connection).and_return(connection)
        end

        it "calls the carta /counters/increment endpoint with the argument id as a param", :aggregate_failures do
          expect { described_class.perform }.to raise_error(Carta::BulkIndexUpdater::CartaBulkUpdateFailed)
          stubs.verify_stubbed_calls
        end
      end

      context "when carta responds with 401" do
        let(:response) do
          [
            401,
            { 'Content-Type': "application/json" }
          ]
        end

        before do
          allow(described_class).to receive(:connection).and_return(connection)
        end

        it "calls the carta /counters/increment endpoint with the argument id as a param", :aggregate_failures do
          expect { described_class.perform }.to raise_error(Carta::BulkIndexUpdater::CartaBulkUpdateFailed)
          stubs.verify_stubbed_calls
        end
      end
    end
  end
end
