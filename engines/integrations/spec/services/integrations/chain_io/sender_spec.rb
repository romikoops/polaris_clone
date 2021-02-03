# frozen_string_literal: true

require "rails_helper"

module Integrations
  module ChainIo
    RSpec.describe Sender do
      describe "Sending the json  chain.io" do
        let(:organization) { FactoryBot.create(:organizations_organization) }

        let(:data) {
          {shipments:
            [{lading_port: {unlocode: "", description: "Gothenburg, SE"},
              departure_estimated: "2019-11-28T02:00:00.000Z",
              arrival_port: {unlocode: "", description: "Gothenburg, SE"},
              arrival_port_estimated: "2019-12-02T00:00:00.000Z",
              freight_payment_terms: "Collect",
              inco_term: "",
              consignee:
              {source_party_id: "e3160ae3-053a-4f46-8e41-3065c10f8f73",
               target_party_id: "",
               name: "John6 Smith6",
               address_1: "",
               address_2: "",
               city: "Gothenburg",
               state: "",
               state_name: "",
               country: "SE",
               country_name: "",
               postal_code: "43813",
               phone_number: "12345676",
               unlocode: ""},
              consignor:
                {source_party_id: "04bfa86f-a230-4a1c-a6da-a12621644d4f",
                 target_party_id: "",
                 name: "John5 Smith5",
                 address_1: "",
                 address_2: "",
                 city: "Gothenburg",
                 state: "",
                 state_name: "",
                 country: "SE",
                 country_name: "",
                 postal_code: "43813",
                 phone_number: "12345675",
                 unlocode: ""},
              containerization_type: "FCL",
              containers:
                  [{container_number: "", delivery_mode: "", size_code: "42GP", type_code: "42GP"},
                    {container_number: "", delivery_mode: "", size_code: "22GP", type_code: "22GP"},
                    {container_number: "", delivery_mode: "", size_code: "22GP", type_code: "22GP"}],
              created_by: {username: "John Smith",
                           email: "demo13@itsmycargo.test",
                           first_name: "John",
                           last_name: "Smith"},
              transport_mode: "ocean",
              package_group: []}]}
        }
        let!(:chainio_stub_req) {
          stub_request(:post, "https://webhooks.chain.io/flow/test_flow_id/booking")
            .with(
              headers: {"X-API-KEY" => "test_api_key"},
              body: data.to_json
            )
            .to_return(status: 200)
        }
        before {
          organization.scope.update(content: {
            integrations: {
              chainio: {
                flow_id: "test_flow_id",
                api_key: "test_api_key"
              }
            }
          })
        }

        it "sends a json to chainIo successfully" do
          described_class.new(data: data, organization_id: organization.id).send_shipment
          expect(chainio_stub_req).to have_been_requested
        end
      end
    end
  end
end
