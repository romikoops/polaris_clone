# frozen_string_literal: true

require "rails_helper"

module Carta
  RSpec.describe Client do
    let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
    let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
    let(:result) { Carta::Result.new({ "id": "itsmycargo:locode:ABC123" }) }
    let(:lookup_resp) { '{"data": {"id": "itsmycargo:locode:ABC123"} }' }
    let(:server_error_response) do
      [
        503,
        { 'Content-Type': "application/json" },
        "<html><body><h1>503 Service Unavailable</h1>
        No server is available to handle this request.
        </body></html>"
      ]
    end

    before do
      allow(described_class).to receive(:connection).and_return(conn)
    end

    describe "#lookup" do
      let(:geo_id) { "123" }

      context "when carta responds with 200 and a result" do
        before do
          stubs.get("/lookup?id=#{geo_id}") do
            [
              200,
              { 'Content-Type': "application/json" },
              lookup_resp
            ]
          end
        end

        it "calls the carta /lookup endpoint with the argument id as a param", :aggregate_failures do
          expect(described_class.lookup(id: geo_id)).to eq(result)
          stubs.verify_stubbed_calls
        end
      end

      context "when carta responds with 200 and no result" do
        before do
          stubs.get("/lookup?id=#{geo_id}") do
            [
              200,
              { 'Content-Type': "application/json" },
              '{"data": {} }'
            ]
          end
        end

        it "calls the carta /lookup endpoint with the argument id as a param", :aggregate_failures do
          expect { described_class.lookup(id: geo_id) }.to raise_error(Carta::Client::LocationNotFound)
          stubs.verify_stubbed_calls
        end
      end

      context "when carta responds with 503" do
        before do
          stubs.get("/lookup?id=#{geo_id}") do
            server_error_response
          end
        end

        it "retries after 1 second", :aggregate_failures do
          expect { described_class.lookup(id: geo_id) }.to raise_error(Carta::Client::ServiceUnavailable)
          stubs.verify_stubbed_calls
        end
      end
    end

    describe "#suggest" do
      let(:locode) { "DEHAM" }

      context "when carta responds with 200 and a result" do
        before do
          stubs.get("/lookup?id=itsmycargo:locode:ABC123") do
            [200, { 'Content-Type': "application/json" }, lookup_resp]
          end
          stubs.get("/suggest?query=#{locode}") do
            [
              200,
              { 'Content-Type': "application/json" },
              '{"data": [{"id": "itsmycargo:locode:ABC123"}] }'
            ]
          end
        end

        it "calls the carta /suggest endpoint with the argument query as a param", :aggregate_failures do
          expect(described_class.suggest(query: locode)).to eq(result)
          stubs.verify_stubbed_calls
        end
      end

      context "when carta responds with 200 and has no result" do
        before do
          stubs.get("/suggest?query=#{locode}") do
            [
              200,
              { 'Content-Type': "application/json" },
              '{"data": [] }'
            ]
          end
        end

        it "calls the carta /suggest endpoint with the argument query as a param", :aggregate_failures do
          expect { described_class.suggest(query: locode) }.to raise_error(Carta::Client::LocationNotFound)
          stubs.verify_stubbed_calls
        end
      end

      context "when carta responds with 503" do
        before do
          stubs.get("/suggest?query=#{locode}") do
            server_error_response
          end
        end

        it "retries after 1 second", :aggregate_failures do
          expect { described_class.suggest(query: locode) }.to raise_error(Carta::Client::ServiceUnavailable)
          stubs.verify_stubbed_calls
        end
      end
    end
  end
end
