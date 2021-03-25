require "rails_helper"

module Carta
  RSpec.describe Client do

    let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
    let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
    let(:client) { described_class }

    let(:geo_id) { '123' }
    let(:lookup_resp) { '{"data": {"id": "itsmycargo:locode:ABC123"} }' }
    let(:result) { Carta::Result.new({"id": "itsmycargo:locode:ABC123"}) }

    before do
      allow(client).to receive(:connection).and_return(conn)
    end

    describe "#lookup" do
      it 'calls the carta /lookup endpoint with the arugment id as a param' do
        stubs.get("/lookup?id=#{geo_id}") do |env|
          expect(env.url.path).to eq('/lookup')
          [
            200,
            { 'Content-Type': 'application/json' },
            lookup_resp
          ]
        end

        expect(client.lookup(id: geo_id)).to eq(result)
        stubs.verify_stubbed_calls
      end

      context "when carta responds with 503" do
        it 'retries after 1 second' do
          stubs.get("/lookup?id=#{geo_id}") do |env|
            expect(env.url.path).to eq('/lookup')
            [
              503,
              { 'Content-Type': 'application/json' },
              '{}'
            ]
          end

          expect { client.lookup(id: geo_id) }.to raise_error(Carta::Client::LocationNotFound)
          stubs.verify_stubbed_calls
        end
      end
    end

    describe "#suggest" do
      let(:suggest_resp) { '{"data": [{"id": "itsmycargo:locode:ABC123"}] }' }
      let(:locode) { 'DEHAM' }

      before do
        stubs.get("/lookup?id=itsmycargo:locode:ABC123") do |env|
          [200, { 'Content-Type': 'application/json' }, lookup_resp]
        end
      end

      it 'calls the carta /suggest endpoint with the arugment query as a param' do
        stubs.get("/suggest?query=#{locode}") do |env|
          expect(env.url.path).to eq("/suggest")
          [
            200,
            { 'Content-Type': 'application/json' },
            suggest_resp
          ]
        end

        expect(client.suggest(query: locode)).to eq(result)
        stubs.verify_stubbed_calls
      end
    end
  end
end