# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "countries", type: :request, swagger: true do
  path "/v2/countries" do
    get "Fetch a list of countries" do
      tags "countries"
      description "fetch a list of countries"
      operationId "getCountries"
      produces "application/json"

      response "200", "successful operation" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: {
                    type: :string
                  },
                  type: {
                    type: :string
                  },
                  attributes: {
                    type: :object,
                    properties: {
                      id: {
                        type: :integer,
                        description: "Id of the countries object"
                      },
                      name: {
                        description: "Name of the country",
                        type: :string
                      },
                      code: {
                        description: "Country code",
                        type: :string
                      },
                      flag: {
                        description: "Url to retrieve flag svg",
                        type: :string
                      }
                    }
                  }
                }
              }
            }
          },
          required: ["data"]

        run_test!
      end
    end
  end
end
