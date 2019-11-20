# frozen_string_literal: true

require 'rails_helper'

RSpec.resource 'Users' do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'

  let(:tenant) { FactoryBot.create(:tenants_tenant) }

  get '/v1/ahoy/:id/settings' do
    response_field :id, 'Tenant Id', Type: String
    let(:id) { tenant.id }

    response_field :endpoint, 'Endpoint url that Ahoy will redirect to start the booking process', Type: String
    response_field :pre_carriage, 'Pre carriage enabled?', Type: :boolean
    response_field :on_carriage, 'On carriage enabled?', Type: :boolean

    mot_properties = {
      fcl: {
        type: :boolean,
        description: 'Container Available (FCL)'
      },
      lcl: {
        type: :boolean,
        description: 'Cargo Item Available (LCL)'
      }
    }

    response_field :modes_of_transport,
                   'Available Modes of transport',
                   Type: 'Object',
                   'properties': {
                     air: {
                       type: :object,
                       description: 'Air',
                       properties: mot_properties
                     },
                     rail: {
                       type: :object,
                       description: 'Rail',
                       properties: mot_properties
                     },

                     ocean: {
                       type: :object,
                       description: 'Ocean',
                       properties: mot_properties
                     },

                     truck: {
                       type: :object,
                       description: 'Truck',
                       properties: mot_properties
                     }
                   }

    example_request 'Returns ahoy settings' do
      explanation <<-DOC
        Use this endpoint to return the ahoy settings for a specific tenant
      DOC
      expect(status).to eq 200
    end
  end
end
