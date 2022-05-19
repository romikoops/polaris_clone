# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Companies", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_user).tap { |users_user| FactoryBot.create(:users_membership, organization: organization, user: users_user) } }
  let(:clients) { FactoryBot.create_list(:users_client, 5, organization: organization) }
  let(:group) { FactoryBot.create(:groups_group, name: "default", organization: organization) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let(:germany) { factory_country_from_code(code: "DE") }
  let!(:companies_company) { FactoryBot.create(:companies_company, organization: organization, email: "foo@bar.com", name: "company1", phone: "112233", vat_number: "DE-VATNUMBER1", address: hamburg_address) }
  let(:company_id) { companies_company.id }
  let(:hamburg_address) { FactoryBot.create(:hamburg_address) }
  let(:shipment_request_status) { "requested" }

  before do
    Organizations.current_id = organization_id
    FactoryBot.create(:companies_company, organization: organization, name: "default")
    FactoryBot.create(:journey_shipment_request, company_id: companies_company.id, status: shipment_request_status)
    Geocoder::Lookup::Test.set_default_stub([
      "address_components" => [{ "types" => ["premise"] }],
      "coordinates" => [54.2967559, 9.7094068],
      "address" => "Brooktorkai 70 Hamburg 20457",
      "street" => "Brooktorkai",
      "street_number" => "70",
      "city" => "Hamburg",
      "country" => "Germany",
      "country_code" => "DE",
      "postal_code" => "20457"
    ])
  end

  path "/v1/organizations/{organization_id}/companies/{company_id}" do
    put "Update a company" do
      tags "Companies"
      description "Update a specific company"
      operationId "updateCompany"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :company_id, in: :path, type: :string, description: "The current company id"
      parameter name: :query, in: :body, schema: {
        type: :object,
        properties: {
          company: {
            type: :object,
            properties: {
              email: { type: :string, description: "The email address of the company" },
              name: { type: :string, description: "The name of the company" },
              paymentTerms: { type: :string, description: "The payment terms, set out by the company" },
              phone: { type: :string, description: "The phone number of the company" },
              vatNumber: { type: :string, description: "The VAT number of the company" }
            }
          }
        }
      }

      response "200", "successful operation" do
        let(:query) do
          {
            company: {
              email: "awesome@company.com",
              name: "awesome company",
              paymentTerms: "an awesome payment term",
              phone: "112233",
              vatNumber: "VAT12345"
            }
          }
        end

        schema type: :object,
          properties: {
            data: {
              "$ref" => "#/components/schemas/company"
            }
          },
          required: ["data"]

        run_test!
      end

      response "422", "Unprocessable Entity" do
        let(:query) { { company: { foo: "bar" } } }

        run_test!
      end
    end
  end

  path "/v2/organizations/{organization_id}/admin/companies/{company_id}" do
    get "Fetch a company" do
      tags "Companies"
      description "Fetch a specific company"
      operationId "getCompany"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :company_id, in: :path, type: :string, description: "The current company id"

      response "200", "successful operation" do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                attributes: { "$ref" => "#/components/schemas/company" }
              }
            }
          },
          required: ["data"]

        run_test!
      end

      response "404", "not found operation" do
        let(:company_id) { "non-existent-id" }

        run_test!
      end
    end

    put "Update a company" do
      tags "Companies"
      description "Update a specific company"
      operationId "updateCompany"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :company_id, in: :path, type: :string, description: "The current company id"
      parameter name: :query, in: :body, schema: {
        type: :object,
        properties: {
          company: {
            type: :object,
            properties: {
              email: { type: :string, description: "The email address of the company" },
              name: { type: :string, description: "The name of the company" },
              paymentTerms: { type: :string, description: "The payment terms, set out by the company" },
              phone: { type: :string, description: "The phone number of the company" },
              vatNumber: { type: :string, description: "The VAT number of the company" },
              address: { type: :object, properties: {
                street: { type: :string, description: "The street name of the company" },
                streetNumber: { type: :string, description: "The street number of the company" },
                zipCode: { type: :string, description: "Zip code of the company" },
                city: { type: :string, description: "city name of the company" },
                countryId: { type: :string, description: "country id associated to the address" }
              } }
            }
          }
        }
      }

      response "200", "successful operation" do
        let(:query) do
          {
            company: {
              email: "awesome@company.com",
              name: "awesome company",
              paymentTerms: "an awesome payment term",
              phone: "112233",
              vatNumber: "VAT12345",
              address: {
                countryId: germany.id,
                street: hamburg_address.street,
                streetNumber: "70",
                zipCode: hamburg_address.zip_code,
                city: hamburg_address.city
              }
            }
          }
        end

        schema type: :object,
          properties: {
            data: {
              "$ref" => "#/components/schemas/company"
            }
          },
          required: ["data"]

        run_test!
      end

      response "422", "Unprocessable Entity" do
        let(:query) { { company: { foo: "bar" } } }

        run_test!
      end
    end

    delete "Delete a company" do
      tags "Companies"
      description "Delete a specific company"
      operationId "deleteCompany"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :company_id, in: :path, type: :string, description: "The current company id"

      response "200", "successful operation" do
        let(:shipment_request_status) { "completed" }

        run_test!
      end

      response "401", "Unauthorized" do
        let(:user) { FactoryBot.create(:users_client, organization_id: organization_id) }
        run_test!
      end
    end
  end

  path "/v2/organizations/{organization_id}/admin/companies" do
    get "Fetch companies" do
      tags "Companies"
      description "Fetches list of companies"
      operationId "getCompanies"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :perPage, in: :query, type: :integer, description: "number of companies per page"
      parameter name: :page, in: :query, type: :integer, description: "current page number"
      parameter name: :sortBy,
        in: :query,
        type: :string,
        description: "The attribute by which to sort the Companies",
        enum: %w[name country activity]
      parameter name: :direction,
        in: :query,
        type: :string,
        description: "The defining whether the sorting is ascending or descending",
        enum: %w[asc desc]
      parameter name: :searchBy,
        in: :query,
        type: :string,
        description: "The attribute of the Company and its related models to search through",
        enum: %w[name_search country_search activity_search]
      parameter name: :searchQuery,
        in: :query,
        type: :string,
        description: "The value we want to use in our search"

      parameter name: :beforeDate,
        in: :query,
        type: :string,
        description: "To filter companies which updated queries before a specific date in `YYYY-mm-dd` format default being today"

      parameter name: :afterDate,
        in: :query,
        type: :string,
        description: "To filter companies which updated queries after a specific date in `YYYY-mm-dd` format"

      let(:perPage) { 2 }
      let(:page) { 1 }
      let(:sortBy) { "name" }
      let(:direction) { "desc" }
      let(:searchBy) { "country" }
      let(:searchQuery) { companies_company.country.name }
      let(:beforeDate) { Time.zone.today.to_s }
      let(:afterDate) { 2.weeks.ago.to_s }

      response "200", "successful operation" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  attributes: { "$ref" => "#/components/schemas/company" }
                }
              }
            }
          },
          required: ["data"]

        run_test!
      end

      response "401", "Unauthorized" do
        let(:access_token) do
          FactoryBot.create(:access_token,
            resource_owner_id: FactoryBot.create(:users_client, organization_id: organization_id).id,
            scopes: "public")
        end
        run_test!
      end

      response "422", "Unprocessable Entity" do
        let(:searchQuery) { nil }
        schema type: :object,
          properties: {
            errors: {
              type: :object,
              properties: {
                search_by: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      error_code: {
                        type: :string,
                        description: "describes 422 errors with self explanatory error code `SEARCH_QUERY_MISSING`"
                      },
                      error_message: {
                        type: :string,
                        description: "describes the reason for the error"
                      }
                    }
                  }
                }
              }
            }
          }
        run_test!

        let(:searchBy) { "price" }
        schema type: :object,
          properties: {
            errors: {
              type: :object,
              properties: {
                search_by: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      error_code: {
                        type: :string,
                        description: "describes 422 errors with self explanatory error code `INVALID_SEARCH_BY_OPTION`"
                      },
                      error_message: {
                        type: :string,
                        description: "describes the reason for the error with the options to be used for search by"
                      }
                    }
                  }
                }
              }
            }
          }
        run_test!

        let(:beforeDate) { "12/12/1975" }
        schema type: :object,
          properties: {
            errors: {
              type: :object,
              properties: {
                date: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      error_code: {
                        type: :string,
                        description: "describes 422 errors with self explanatory error code `INVALID_DATE`"
                      },
                      error_message: {
                        type: :string,
                        description: "describes the reason for the error with the options to be used for search by"
                      }
                    }
                  }
                }
              }
            }
          }
        run_test!
      end
    end

    post "Create new company" do
      tags "Companies"
      description "Create new company"
      operationId "createCompany"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :company_params, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, description: "The email address of the company" },
          name: { type: :string, description: "The name of the company" },
          paymentTerms: { type: :string, description: "The payment terms, set out by the company", nullable: true },
          phone: { type: :string, description: "The phone number of the company", nullable: true },
          vatNumber: { type: :string, description: "The VAT number of the company", nullable: true  },
          contactPersonName: { type: :string, description: "The name of the contact person/employee from the company", nullable: true },
          contactPhone: { type: :string, description: "The phone number of the contact person from the company", nullable: true },
          contactEmail: { type: :string, description: "The email of the contact person from the company", nullable: true },
          registrationNumber: { type: :string, description: "The registration number set by company", nullable: true }
        }
      }

      let(:company_params) do
        {
          name: "test-company",
          email: "company@test-company.com",
          phone: "1234567890",
          paymentTerms: "some payment terms example",
          vatNumber: "vat12",
          contactPersonName: "John Doe",
          contactPhone: "9876543210",
          contactEmail: "contact@test-company.com",
          registrationNumber: "reg987"
        }
      end

      response "201", "company creation success" do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                attributes: { "$ref" => "#/components/schemas/company" }
              }
            }
          },
          required: ["data"]

        run_test!
      end

      response "422", "Unprocessable Entity" do
        let!(:companies_company) { FactoryBot.create(:companies_company, organization_id: organization_id, name: company_params[:name], email: company_params[:email]) }
        run_test!
      end

      response "401", "Unauthorized" do
        let(:user) { FactoryBot.create(:users_client, organization_id: organization_id) }
        run_test!
      end
    end
  end
end
