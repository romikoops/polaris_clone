# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # rubocop:disable Naming/VariableNumber
  # Auto-generate example
  config.after(:each, swagger: true) do |example|
    if response && response.body.present?
      example.metadata[:response][:content] = {
        "application/json" => { example: JSON.parse(response.body, symbolize_names: true) }
      }
    end
  end

  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join("doc/api").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    "swagger.json" => {
      openapi: "3.0.1",
      info: {
        title: "Polaris API",
        description: "ItsMyCargo Backend API",
        termsOfService: "https://www.itsmycargo.com/terms",
        contact: {
          name: "API Support",
          url: "https://support.itsmycargo.com",
          email: "support@itsmycargo.com"
        },
        version: Time.zone.today.to_s
      },
      tags: [
        { name: "Ahoy", description: "Ahoy" },
        {
          name: "Authentication",
          description: %(Endpoints related to the current user and authentication.)
        },
        { name: "CargoUnits", description: "CargoUnits" },
        { name: "Clients", description: "Clients" },
        { name: "Dashboard", description: "Dashboard" },
        { name: "Groups", description: "Groups" },
        { name: "Query", description: "Query" },
        { name: "Quote", description: "Quote" },
        { name: "Results", description: "Results" },
        { name: "Trucking", description: "Trucking" },
        { name: "Users", description: "Users" }
      ],
      components: {
        schemas: {
          errors: {
            type: "object",
            properties: {
              errors: {
                type: "object",
                properties: {
                  message: {
                    description: "error message",
                    type: "string"
                  }
                },
                additionalProperties: {
                  type: "array",
                  items: { type: "string" }
                }
              }
            }
          },
          company: {
            type: "object",
            properties: {
              id: {
                description: "Unique identifier of the company",
                type: "string"
              },
              type: {
                description: "Generic type of the company",
                type: "string"
              },
              attributes: {
                id: {
                  description: "Unique identifier of the company",
                  type: "string"
                },
                email: {
                  description: "email of the company",
                  type: "string"
                },
                name: {
                  description: "name of the company",
                  type: "string"
                },
                paymentTerms: {
                  description: "payment terms set out by the company",
                  type: "string"
                },
                phone: {
                  description: "phone number of the company",
                  type: "string"
                },
                vatNumber: {
                  description: "VAT number of the company",
                  type: "string"
                },
                contactPersonName: {
                  description: "The name of the contact person/employee from the company",
                  type: "string"
                },
                contactPhone: {
                  description: "The phone number of the contact person from the company",
                  type: "string"
                },
                contactEmail: {
                  description: "The email of the contact person from the company",
                  type: "string"
                },
                registrationNumber: {
                  description: "The registration number set by company",
                  type: "string"
                },
                address: {
                  type: "object",
                  description: "Address details of the company",
                  properties: { "$ref" => "#/components/schemas/address" },
                  nullable: true
                },
                lastActivityAt: {
                  description: "Updated_at timestamp for the last query updated by the company",
                  type: "string",
                  nullable: true
                }
              }
            }
          },
          admin_user: {
            type: "object",
            properties: {
              id: {
                description: "Unique identifier of the admin user",
                type: "string"
              },
              type: {
                description: "Generic type of the company",
                type: "string"
              },
              attributes: {
                id: {
                  description: "Unique identifier of the company",
                  type: "string"
                },
                email: {
                  description: "email of the company",
                  type: "string"
                },
                firstName: {
                  description: "first name of the admin user",
                  type: "string"
                },
                lastName: {
                  description: "last name of the admin user",
                  type: "string"
                },
                phone: {
                  description: "phone number of the admin user",
                  type: "string"
                },
                language: {
                  type: "string",
                  pattern: "[a-z]{2}-[A-Z]{2}",
                  description: <<~DOC
                    User's preferred language. Preferred language is given as language
                    and country combination, allowing different dialects and languages
                    for each region.

                    Language code is combined with language and country, separated by
                    dash. First part of the code, language is the lower-case
                    two-letter codes as defined by ISO-639-1. Second part is the
                    upper-case two-letter codes as defined by ISO-3166-1.

                    Ex:

                    * `en-US` - English as spoken in United States of America
                    * `en-GB` - English as spoken in United Kingdom and the Northern Ireland
                    * `sv-FI` - Swedish as spoken in Finland
                  DOC
                },
                locale: {
                  type: "string",
                  pattern: "[a-z]{2}-[A-Z]{2}",
                  description: <<~DOC
                    User's preferred locale. Preferred locale defines how numbers and
                    currencies, time et al. are displayed in the shop.

                    Locale code is combined with language and country, separated by
                    dash. First part of the code, language is the lower-case
                    two-letter codes as defined by ISO-639-1. Second part is the
                    upper-case two-letter codes as defined by ISO-3166-1.

                    Ex:

                    * `en-US` - English as spoken in United States of America
                    * `en-GB` - English as spoken in United Kingdom and the Northern Ireland
                    * `sv-FI` - Swedish as spoken in Finland
                  DOC
                },
                currency: {
                  type: "string",
                  description: <<~DOC
                    The preferred currency of the admin user, there is no check if the currency is valid or supported.
                    It is for the caller to send the right currency as uppercase.

                    Ex:

                    * `USD` - US Doller
                    * `EU` - Euro
                    * We only support two currencies for now *
                  DOC
                },
                authMethods: {
                  type: "array",
                  description: "This contains the auth methods this Organization accepts",
                  schema: "string"
                },
                loginSamlText: {
                  type: "string",
                  description: "Custom text to be displayed in the 'Log in Via SAML' button"
                }
              }
            }
          },
          address: {
            type: "object",
            properties: {
              id: {
                description: "Unique identifier of the address",
                type: "integer"
              },
              type: {
                description: "Generic type of the address",
                type: "string"
              },
              attributes: {
                id: {
                  description: "Unique identifier of the address",
                  type: "integer"
                },
                streetNumber: {
                  description: "Street number of the address.",
                  type: "string",
                  nullable: true
                },
                street: {
                  description: "Street details of the address",
                  type: "string",
                  nullable: true
                },
                city: {
                  description: "City name",
                  type: "string",
                  nullable: true
                },
                postalCode: {
                  description: "PostalCode",
                  type: "string",
                  nullable: true
                },
                country: {
                  type: "object",
                  description: "Country details of the company",
                  properties: { "$ref" => "#/components/schemas/country" },
                  nullable: true
                }
              }
            }
          },
          request_for_quotation: {
            type: "object",
            properties: {
              id: {
                description: "Unique identifier for request_for_quotation",
                type: "string"
              },
              type: {
                description: "Generic type of the request_for_quotation",
                type: "string"
              },
              attributes: {
                id: {
                  description: "Unique identifier for request_for_quotation",
                  type: "string"
                },
                email: {
                  description: "Email of the client requesting for quotation.",
                  type: "string"
                },
                fullName: {
                  description: "Full Name of the client requesting for quotation.",
                  type: "string"
                },
                phone: {
                  description: "Phone number of the client requesting for quotation.",
                  type: "string"
                },
                companyName: {
                  description: "Company name of the client. For a guest user, company name is empty",
                  type: "string"
                },
                organizationId: {
                  description: "Organization ID",
                  type: "string"
                },
                queryId: {
                  description: "Query ID",
                  type: "string"
                }
              }
            }
          },
          file_descriptor: {
            type: "object",
            properties: {
              id: {
                description: "Unique identifier for file_descriptor",
                type: "string"
              },
              type: {
                description: "Generic type of the file_descriptor",
                type: "string"
              },
              attributes: {
                organizationId: {
                  description: "Organization ID",
                  type: "string"
                },
                filePath: {
                  description: "File path description of a file with its name.",
                  type: "string"
                },
                originator: {
                  description: "Datasource  of the file ex: 'SFTP'.",
                  type: "string"
                },
                source: {
                  description: "source folder name or bucket name depending on the source_type",
                  type: "string"
                },
                source_type: {
                  description: "describes the source ex : S3_BUCKET",
                  type: "string"
                },
                fileCreatedAt: {
                  description: "The birth date and time of the file even before it was synced.",
                  type: "string"
                },
                fileUpdatedAt: {
                  description: "File updated at date and time in its originator.",
                  type: "string"
                },
                syncedAt: {
                  description: "Date and time when the file was synced to the source.",
                  type: "string"
                }
              }
            }
          },
          contact: {
            type: "object",
            properties: {
              address_line_1: {
                description: "Address line 1",
                nullable: true,
                type: "string"
              },
              address_line_2: {
                description: "address line 2",
                nullable: true,
                type: "string"
              },
              address_line_3: {
                description: "address line 3",
                nullable: true,
                type: "string"
              },
              city: {
                description: "City",
                nullable: true,
                type: "string"
              },
              company_name: {
                description: "Company name",
                nullable: true,
                type: "string"
              },
              country_code: {
                description: "Country code",
                nullable: true,
                type: "string"
              },
              email: {
                description: "Email address",
                type: "string"
              },
              function: {
                description: "Function",
                nullable: true,
                type: "string"
              },
              geocoded_address: {
                description: "Geocoded address",
                nullable: true,
                type: "string"
              },
              name: {
                description: "Name",
                nullable: true,
                type: "string"
              },
              phone: {
                description: "Phone",
                nullable: true,
                type: "string"
              },
              point: {
                description: "Point",
                nullable: true,
                type: "string"
              },
              postal_code: {
                description: "Postal code",
                nullable: true,
                type: "string"
              }
            },
            required: %w[email]
          },
          shipment_request_index: {
            type: "object",
            properties: {
              result_id: {
                description: "Result ID",
                type: "string"
              },
              company_id: {
                description: "Company ID",
                type: "string"
              },
              client_id: {
                description: "Client ID",
                type: "string"
              },
              with_insurance: {
                description: "Any insurance on the cargo",
                type: "boolean",
                nullable: true
              },
              with_customs_handling: {
                description: "Any customs handling service needed",
                type: "boolean",
                nullable: true
              },
              status: {
                description: "Status of the shipment request",
                type: "string",
                nullable: true
              },
              preferred_voyage: {
                description: "Preferred voyage",
                type: "string",
                nullable: true
              },
              notes: {
                description: "Notes about the shipment request",
                type: "string",
                nullable: true
              },
              originHub: {
                description: "Name of the Hub the shipment departs from",
                type: "string"
              },
              destinationHub: {
                description: "Name of the Hub the shipment arrives at.",
                type: "string"
              },
              originPickup: {
                description: "Address where the cargo will be collected if Pre-Carriage is requested",
                type: "string",
                nullable: true
              },
              destinationDropoff: {
                description: "Address where the cargo will be dropped off if On-Carriage is requested",
                type: "string",
                nullable: true
              },
              requestedAt: {
                description: "Date the ShipmentRequest was made",
                type: "string"
              },
              reference: {
                description: "The internal reference number from the LineItemSet used to generate the ShipmentRequest",
                type: "string"
              }
            }
          },
          shipment_request_admin_index: {
            type: "object",
            properties: {
              result_id: {
                description: "Result ID",
                type: "string"
              },
              company_id: {
                description: "Company ID",
                type: "string"
              },
              client_id: {
                description: "Client ID",
                type: "string"
              },
              with_insurance: {
                description: "Any insurance on the cargo",
                type: "boolean",
                nullable: true
              },
              with_customs_handling: {
                description: "Any customs handling service needed",
                type: "boolean",
                nullable: true
              },
              status: {
                description: "Status of the shipment request",
                type: "string",
                nullable: true
              },
              preferred_voyage: {
                description: "Preferred voyage",
                type: "string",
                nullable: true
              },
              notes: {
                description: "Notes about the shipment request",
                type: "string",
                nullable: true
              },
              originHub: {
                description: "Name of the Hub the shipment departs from",
                type: "string"
              },
              destinationHub: {
                description: "Name of the Hub the shipment arrives at",
                type: "string"
              },
              originPickup: {
                description: "Address where the cargo will be collected if Pre-Carriage is requested",
                type: "string",
                nullable: true
              },
              destinationDropoff: {
                description: "Address where the cargo will be dropped off if On-Carriage is requested",
                type: "string",
                nullable: true
              },
              requestedAt: {
                description: "Date the ShipmentRequest was made",
                type: "string"
              },
              reference: {
                description: "The internal reference number from the LineItemSet used to generate the ShipmentRequest",
                type: "string"
              },
              client: {
                type: "object",
                properties: {
                  email: {
                    description: "Email",
                    type: "string"
                  },
                  firstName: {
                    description: "First Name",
                    type: "string"
                  },
                  lastName: {
                    description: "Last Name",
                    type: "string"
                  },
                  phone: {
                    description: "Phone",
                    type: "string",
                    nullable: true
                  },
                  lastActivityAt: {
                    description: "client's last activity date and time",
                    type: "string",
                    nullable: true
                  }
                }
              }
            }
          },
          shipment_request: {
            type: "object",
            properties: {
              result_id: {
                description: "Result ID",
                type: "string"
              },
              company_id: {
                description: "Company ID",
                type: "string"
              },
              client_id: {
                description: "Client ID",
                type: "string"
              },
              with_insurance: {
                description: "Any insurance on the cargo",
                type: "boolean",
                nullable: true
              },
              with_customs_handling: {
                description: "Any customs handling service needed",
                type: "boolean",
                nullable: true
              },
              status: {
                description: "Status of the shipment request",
                type: "string",
                nullable: true
              },
              preferred_voyage: {
                description: "Preferred voyage",
                type: "string",
                nullable: true
              },
              notes: {
                description: "Notes about the shipment request",
                type: "string",
                nullable: true
              },
              commercial_value: {
                description: "Commercial value with integer and currency",
                type: "object",
                nullable: true
              },
              contacts_attributes: {
                description: "Array of contact attributes as objects",
                type: "array",
                items: {
                  "$ref": "#/components/schemas/contact"
                }
              }
            }
          },
          shipment_request_params: {
            type: :object,
            properties: {
              withInsurance: {
                type: :boolean,
                nullable: true,
                description: "Any insurance on the cargo"
              },
              withCustomsHandling: {
                type: :boolean,
                nullable: true,
                description: "Any customs handling service needed"
              },
              preferredVoyage: {
                type: "string",
                nullable: true,
                description: "Preferred voyage"
              },
              notes: {
                type: :string,
                nullable: true,
                description: "notes about the shipment request"
              },
              commercialValueCents: {
                nullable: true,
                type: :integer,
                description: "Commercial value as an integer expressed as cent or other equivalent base unit"
              },
              commercialValueCurrency: {
                nullable: true,
                type: :string,
                description: "Commercial value's currency in three letter ISO format"
              },
              contactsAttributes: {
                type: :array,
                description: "Contact info for client",
                items: { "$ref" => "#/components/schemas/contact" }
              },
              documents: {
                type: :array,
                description: "Multipart form upload of files to be attached to the shipment request",
                items: {
                  type: :binary
                }
              }
            },
            required: %w[
              withInsurance
              withCustomsHandling
              preferredVoyage
              notes
              commercialValueCents
              commercialValueCurrency
              contactsAttributes
            ]
          },
          theme: {
            type: "object",
            properties: {
              organization_id: {
                description: "Organization ID",
                type: "string"
              },
              name: {
                description: "Name of the organization",
                type: "string"
              },
              background: {
                description: "Link to uploaded background image",
                type: "string",
                nullable: true
              },
              small_logo: {
                description: "Small size logo of the organization",
                type: "string",
                nullable: true
              },
              white_logo: {
                large_logo: "Logo with white background",
                type: "string",
                nullable: true
              },
              wide_logo: {
                description: "Wide logo of the organization",
                type: "string",
                nullable: true
              },
              landing_page_variant: {
                description: "Custom theme landing page variants with options such as `default` `quotation_plugin` and `light`",
                type: "string",
                enum: %w[default quotation_plugin light],
                nullable: true
              },
              landing_page_hero: {
                description: "Main landing page similar to background",
                type: "string",
                nullable: true
              },
              landing_page_one: {
                description: "First landing page image",
                type: "string",
                nullable: true
              },
              landing_page_two: {
                description: "Second landing page image",
                type: "string",
                nullable: true
              },
              landing_page_three: {
                description: "Third landing page image",
                type: "string",
                nullable: true
              },
              color_scheme: {
                description: "Set of color schemes specific to an organization",
                type: "object",
                nullable: true
              },
              emails: {
                description: "List of emails",
                type: "object",
                items: {
                  sales: {
                    description: "sales email",
                    type: "object",
                    items: {
                      general: {
                        description: "general sales email",
                        type: "object"
                      }
                    }
                  },
                  support: {
                    description: "support email",
                    type: "object",
                    items: {
                      general: {
                        description: "general support email",
                        type: "object"
                      }
                    }
                  }
                }
              },
              websites: {
                description: "websites of the organzation",
                type: "object",
                nullable: true
              },
              phones: {
                description: "phone numbers of the organization",
                type: "object",
                nullable: true,
                items: {
                  main: {
                    description: "organizations main phone number",
                    type: "string"
                  },
                  support: {
                    description: "organizations support phone number",
                    type: "string"
                  }
                }
              },
              addresses: {
                description: "phone numbers of the organization",
                type: "object",
                nullable: true,
                items: {
                  main: {
                    description: "organizations main address",
                    type: "string"
                  },
                  components: {
                    description: "organization address components",
                    type: "array"
                  }
                }
              }
            }
          },
          cargo_item_type: {
            type: "object",
            properties: {
              id: {
                description: "Unique identifier of the given cargo item type",
                type: "string"
              },
              type: {
                description: "Generic type of the cargo item",
                type: "string"
              },
              attributes: {
                type: "object",
                properties: {
                  width: {
                    description: "Width of the given cargo item type",
                    type: "string",
                    nullable: true,
                    deprecated: true
                  },
                  length: {
                    description: "Length of the given cargo item type",
                    type: "string",
                    nullable: true,
                    deprecated: true
                  },
                  description: {
                    description: "Descriptive information of the cargo item type",
                    type: "string"
                  }
                },
                required: %w[width length]
              }
            },
            required: %w[
              id
              type
              attributes
            ]
          },
          carrier: {
            type: "object",
            properties: {
              id: {
                description: "Unique identifier of the given Carrier",
                type: "string"
              },
              type: {
                description: "Generic type of the Carrier",
                type: "string"
              },
              attributes: {
                type: "object",
                properties: {
                  id: {
                    description: "The ID of the Carrier record",
                    type: "string"
                  },
                  name: {
                    description: "The Carrier's name",
                    type: "string"
                  },
                  code: {
                    description: "The Carrier's code. Preferably SCAC or IATA but customs code are allowed.",
                    type: "string"
                  },
                  logo: {
                    description: "URL for accesing the logo of the Carrier",
                    type: "string",
                    nullable: true
                  }
                },
                required: %w[id name code logo]
              }
            },
            required: %w[
              id
              type
              attributes
            ]
          },
          client: {
            type: "object",
            properties: {
              email: {
                type: "string"
              },
              first_name: {
                type: "string"
              },
              last_name: {
                type: "string"
              },
              company_name: {
                type: "string"
              },
              phone: {
                type: "string"
              },
              house_number: {
                type: "string"
              },
              street: {
                type: "string"
              },
              postal_code: {
                type: "string"
              },
              country: {
                type: "string"
              },
              group_id: {
                type: "string"
              }
            },
            required: %w[
              email
              first_name
              last_name
              company_name
              phone
              house_number
              street
              postal_code
              country
              group_id
            ]
          },
          charge: {
            type: "object",
            properties: {
              id: {
                description: "Charge ID",
                type: "string"
              },
              lineItemId: {
                description: "Line Item",
                type: "string"
              },
              tenderId: {
                description: "Tender",
                type: "string"
              },
              chargeCategoryId: {
                description: "Category of the charge",
                type: "integer"
              },
              description: {
                description: "Description",
                type: "string"
              },
              value: {
                "$ref": "#/components/schemas/money"
              },
              originalValue: {
                "$ref": "#/components/schemas/money"
              },
              order: {
                description: "Order of the charges",
                type: "integer"
              },
              section: {
                description: "Section of charge",
                type: "string"
              },
              level: {
                description: "Nesting level",
                type: "integer"
              },
              rate: {
                description: "The rate at which the LineItem was charged",
                type: "string"
              },
              rateFactor: {
                description: "The value (with unit) that was applied to the Rate to achieve the final price of the LineItem",
                type: "string"
              }
            },
            required: %w[
              id
              lineItemId
              tenderId
              chargeCategoryId
              description
              value
              originalValue
              order
              section
              level
            ]
          },
          v2Charge: {
            type: "object",
            properties: {
              id: {
                description: "Charge ID",
                type: "string"
              },
              description: {
                description: "Description",
                type: "string"
              },
              feeCode: {
                description: "The fee code describing the Charge",
                type: "string"
              },
              value: {
                "$ref": "#/components/schemas/v2Money"
              },
              unitPrice: {
                "$ref": "#/components/schemas/v2Money"
              },
              order: {
                description: "Order of the charges",
                type: "integer"
              },
              section: {
                description: "Section of charge",
                type: "string"
              },
              units: {
                description: "Quantity of cargo this Charge was calculated with",
                type: "integer"
              }
            },
            required: %w[
              id
              description
              feeCode
              value
              unitPrice
              order
              section
              units
            ]
          },
          commodityInfo: {
            type: "object",
            properties: {
              imoClass: {
                type: "string",
                enum: Journey::CommodityInfo::VALID_IMO_CLASSES,
                nullable: true,
                description: <<~DOC
                  Defines the standard IMO class for the dangerous goods that this cargo item might contain. IMO Class is defined as Class and possible sub-class, where class defines top-level category of type of dangerous goods, and sub-class defines more detailed separation of different dangerous goods.

                  To see list of possible classes and sub-classes, please see for example https://www.searates.com/reference/imo/

                  If the cargo item is known to contain dangerous goods, but the specific class is unknown, please use `0` as IMO class, which is used internally for unknown dangerous goods class.
                  If the cargo item is known to contain no dangerous goods, set this field as `null`.
                DOC
              },
              description: {
                type: "string",
                description: "The description of the IMO Class/ HSCode chosen"
              },
              hsCode: {
                type: "string",
                nullable: true,
                description: <<~DOC
                  The Harmonized Commodity Description and Coding System, also known as the Harmonized System of tariff nomenclature is an internationally standardized system of names and numbers to classify traded products.
                  This code is is used to identify the type of cargo being shipped as it can affect the pricing and routes available
                DOC

              }
            },
            required: %w[description hsCode imoClass]
          },
          country: {
            type: "object",
            properties: {
              id: {
                description: "Country ID",
                type: "string"
              },
              type: {
                description: "Country Type",
                type: "string"
              },
              attributes: {
                description: "Country Attributes",
                type: "object",
                properties: {
                  name: {
                    description: "Name of the country",
                    type: "string"
                  },
                  code: {
                    description: "Country code",
                    type: "string"
                  },
                  flag: {
                    description: "Flag of the country",
                    type: "string"
                  }
                },
                required: %w[
                  name
                  code
                  flag
                ]
              }
            },
            required: %w[
              id
              type
              attributes
            ]
          },
          group: {
            type: "object",
            properties: {
              id: {
                description: "Group ID",
                type: "string"
              },
              type: {
                description: "Type of group",
                type: "string"
              },
              attributes: {
                description: "Attributes of group",
                type: "object",
                properties: {
                  id: {
                    description: "ID of attributes",
                    type: "string"
                  },
                  name: {
                    description: "Name of the group",
                    type: "string"
                  }
                },
                required: %w[
                  id
                  name
                ]
              }
            },
            required: %w[
              id
              type
              attributes
            ]
          },
          item: {
            type: "object",
            properties: {
              cargoClass: {
                description: "Cargo classification code",
                type: "string",
                enum: %w[
                  lcl
                  aggregated_lcl
                  fcl_10
                  fcl_20
                  fcl_20_ot
                  fcl_20_rf
                  fcl_20_frs
                  fcl_20_frw
                  fcl_40
                  fcl_40_hq
                  fcl_40_ot
                  fcl_40_rf
                  fcl_40_hq_rf
                  fcl_40_frs
                  fcl_40_frw
                  fcl_45
                  fcl_45_hq
                  fcl_45_rf
                ]
              },
              stackable: {
                description: "If cargo item is stackable or not",
                type: "boolean"
              },
              quantity: {
                description: "Quantity",
                type: "integer"
              },
              length: {
                description: "Length of the item expressed as a decimal on the centimeter (cm) scale",
                type: "number"
              },
              width: {
                description: "Width of the item expressed as a decimal on the centimeter (cm) scale",
                type: "number"
              },
              height: {
                description: "Height of the item expressed as a decimal on the centimeter (cm) scale",
                type: "number"
              },
              weight: {
                description: "Weight of the item expressed as a decimal on the kilogram (kg) scale",
                type: "number"
              },
              volume: {
                description: "Volume of the item expressed as a decimal on the cubic meter (m3) scale",
                type: "number"
              },
              commodities: {
                description: "Commodity codes of the contents",
                type: "array",
                items: { "$ref": "#/components/schemas/commodityInfo" }
              }
            },
            required: %w[
              stackable
              colliType
              quantity
              length
              width
              height
              weight
              commodities
            ]
          },
          item_lcl: {
            type: "object",
            properties: {
              cargoClass: {
                description: "Cargo classification code",
                type: "string",
                enum: [
                  "lcl"
                ]
              },
              stackable: {
                description: "If cargo item is stackable or not",
                type: "boolean"
              },
              colliType: {
                description: "Colli Type: The type of container the items are packed in. One of a preset list",
                type: "string",
                enum: %w[
                  container
                  barrel
                  bottle
                  carton
                  case
                  crate
                  drum
                  package
                  pallet
                  roll
                  skid
                  stack
                  room_temp_reefer
                  low_temp_reefer
                ]
              },
              quantity: {
                description: "Quantity",
                type: "integer"
              },
              length: {
                description: "Length of the item expressed as a decimal on the centimeter (cm) scale",
                type: "number"
              },
              width: {
                description: "Width of the item expressed as a decimal on the centimeter (cm) scale",
                type: "number"
              },
              height: {
                description: "Height of the item expressed as a decimal on the centimeter (cm) scale",
                type: "number"
              },
              weight: {
                description: "Weight of the item expressed as a decimal on the kilogram (kg) scale",
                type: "number"
              },
              commodities: {
                description: "Commodity codes of the contents",
                type: "array",
                items: { "$ref": "#/components/schemas/commodityInfo" }
              }
            },
            required: %w[
              stackable
              colliType
              quantity
              length
              width
              height
              weight
              commodities
              cargoClass
            ]
          },
          item_aggregated_lcl: {
            type: "object",
            properties: {
              cargoClass: {
                description: "Cargo classification code",
                type: "string",
                enum: [
                  "aggregated_lcl"
                ]
              },
              stackable: {
                description: "Aggregated Cargo Item's are always stackable so this property is not required",
                type: "boolean",
                nullable: true
              },
              quantity: {
                description: "Aggregated Cargo Item's have no defined quantity so this property is null",
                type: "integer",
                nullable: true
              },
              length: {
                description: "Aggregated Cargo Item's have no defined length so this property is null",
                type: "number",
                nullable: true
              },
              width: {
                description: "Aggregated Cargo Item's have no defined width so this property is null",
                type: "number",
                nullable: true
              },
              height: {
                description: "Aggregated Cargo Item's have no defined height so this property is null",
                type: "number",
                nullable: true
              },
              weight: {
                description: "Weight of the item expressed as a decimal on the kilogram (kg) scale",
                type: "number"
              },
              volume: {
                description: "Volume of the item expressed as a decimal on the cubic meter (m3) scale",
                type: "number"
              },
              commodities: {
                description: "Commodity codes of the contents",
                type: "array",
                items: { "$ref": "#/components/schemas/commodityInfo" },
                nullable: true
              }
            },
            required: %w[
              volume
              weight
              cargoClass
            ]
          },
          item_fcl: {
            type: "object",
            properties: {
              cargoClass: {
                description: "Container classification code",
                type: "string",
                enum: %w[
                  fcl_10
                  fcl_20
                  fcl_20_ot
                  fcl_20_rf
                  fcl_20_frs
                  fcl_20_frw
                  fcl_40
                  fcl_40_hq
                  fcl_40_ot
                  fcl_40_rf
                  fcl_40_hq_rf
                  fcl_40_frs
                  fcl_40_frw
                  fcl_45
                  fcl_45_hq
                  fcl_45_rf
                ]
              },
              quantity: {
                description: "Quantity",
                type: "integer"
              },
              length: {
                description: "Containers have no defined length so this property is null",
                type: "integer",
                nullable: true
              },
              width: {
                description: "Containers have no defined width so this property is null",
                type: "integer",
                nullable: true
              },
              height: {
                description: "Containers have no defined height so this property is null",
                type: "integer",
                nullable: true
              },
              weight: {
                description: "Weight of the item expressed as a decimal on the kilogram (kg) scale",
                type: "integer"
              },
              volume: {
                description: "Containers have no defined dimensions so this property is null",
                type: "integer"
              },
              commodities: {
                description: "Commodity codes of the contents",
                type: "array",
                items: { "$ref": "#/components/schemas/commodityInfo" }
              }
            },
            required: %w[
              stackable
              colliType
              quantity
              weight
              commodities
              cargoClass
            ]
          },
          validation_item_lcl: {
            allOf: [
              { "$ref": "#/components/schemas/item_lcl" },
              {
                type: "object",
                properties: {
                  id: {
                    description: "A UUID to be used to identify which CargoUnit to render the error on",
                    type: "string"
                  }
                },
                required: %w[id]
              }
            ]
          },
          validation_item_aggregated_lcl: {
            allOf: [
              { "$ref": "#/components/schemas/item_aggregated_lcl" },
              {
                type: "object",
                properties: {
                  id: {
                    description: "A UUID to be used to identify which CargoUnit to render the error on",
                    type: "string"
                  }
                },
                required: %w[id]
              }
            ]
          },
          validation_item_fcl: {
            allOf: [
              { "$ref": "#/components/schemas/item_fcl" },
              {
                type: "object",
                properties: {
                  id: {
                    description: "A UUID to be used to identify which CargoUnit to render the error on",
                    type: "string"
                  }
                },
                required: %w[id]
              }
            ]
          },
          item_response: {
            type: "object",
            properties: {
              attributes: {
                type: "object",
                properties: {
                  cargoClass: {
                    description: "Cargo classification code",
                    type: "string",
                    enum: %w[
                      lcl
                      aggregated_lcl
                      fcl_10
                      fcl_20
                      fcl_20_ot
                      fcl_20_rf
                      fcl_20_frs
                      fcl_20_frw
                      fcl_40
                      fcl_40_hq
                      fcl_40_ot
                      fcl_40_rf
                      fcl_40_hq_rf
                      fcl_40_frs
                      fcl_40_frw
                      fcl_45
                      fcl_45_hq
                      fcl_45_rf
                    ]
                  },
                  stackable: {
                    description: "If cargo item is stackable or not",
                    type: "boolean"
                  },
                  quantity: {
                    description: "Quantity",
                    type: "integer"
                  },
                  length: {
                    description: "Length of the item expressed as a decimal on the centimeter (cm) scale",
                    type: "number"
                  },
                  width: {
                    description: "Width of the item expressed as a decimal on the centimeter (cm) scale",
                    type: "number"
                  },
                  height: {
                    description: "Height of the item expressed as a decimal on the centimeter (cm) scale",
                    type: "number"
                  },
                  weight: {
                    description: "Weight of the item expressed as a decimal on the kilogram (kg) scale",
                    type: "number"
                  },
                  volume: {
                    description: "Volume of the item expressed as a decimal on the cubic meter (m3) scale",
                    type: "number"
                  },
                  commodities: {
                    description: "Commodity codes of the contents",
                    type: "array",
                    items: { "$ref": "#/components/schemas/commodityInfo" }
                  }
                },
                required: %w[
                  stackable
                  colliType
                  quantity
                  length
                  width
                  height
                  weight
                  commodities
                ]
              }
            },
            required: %w[attributes]
          },
          v1CargoItem: {
            type: "object",
            properties: {
              id: {
                type: "string",
                description: "ID of the Cargo Item"
              },
              cargo_class: {
                type: "string",
                description: "Cargo Class of the Cargo Item. Must be `lcl`"
              },
              cargo_item_type_id: {
                type: "string",
                description: "ID of the CargoItemType - repesenting the Colli Type"
              },
              contents: {
                type: "string",
                description: "String desccribin the Items contents",
                nullable: true
              },
              dangerous_goods: {
                type: "boolean",
                description: "Whether or not the Cargoitem contains dangerous goods"
              },
              width: {
                type: "number",
                description: "The width of the item in cm"
              },
              length: {
                type: "number",
                description: "The length of the item in cm"
              },
              height: {
                type: "number",
                description: "The height of the item in cm"
              },
              payload_in_kg: {
                type: "number",
                description: "The individual weight of each item in kg"
              },
              quantity: {
                type: "number",
                description: "The number of identical items in the group"
              },
              stackable: {
                type: "boolean",
                description: "Whether these items can be stacked"
              },
              total_volume: {
                type: "number",
                description: "The total volume of all items in the group in cubic meters"
              },
              total_weight: {
                type: "number",
                description: "The total weight of the group in kg."
              }
            }
          },
          v1Container: {
            type: "object",
            properties: {
              id: {
                type: "string",
                description: "The ID of the Container"
              },
              cargo_class: {
                type: "string",
                description: "The Cargo Class of the Container",
                enum: %w[
                  fcl_10
                  fcl_20
                  fcl_20_ot
                  fcl_20_rf
                  fcl_20_frs
                  fcl_20_frw
                  fcl_40
                  fcl_40_hq
                  fcl_40_ot
                  fcl_40_rf
                  fcl_40_hq_rf
                  fcl_40_frs
                  fcl_40_frw
                  fcl_45
                  fcl_45_hq
                  fcl_45_rf
                ]
              },
              contents: {
                type: "string",
                description: "A string describing the contents of the Container",
                nullable: true
              },
              dangerous_goods: {
                type: "boolean",
                description: "Whether or not the Container holds any dangerous goods"
              },
              payload_in_kg: {
                type: "number",
                description: "The weight of the payload per container in kg"
              },
              quantity: {
                type: "number",
                description: "The number of containers in the group"
              },
              size_class: {
                type: "string",
                description: "Duplicate of Cargo Class: Deprecated",
                deprecated: true
              }
            }
          },
          v1ShipmentInfoContainers: {
            type: :object,
            properties: {
              containers_attributes: {
                type: :array,
                items: { "$ref" => "#/components/schemas/v1Container" }
              },
              trucking_info: {
                type: :object,
                properties: {
                  pre_carriage: { "$ref" => "#/components/schemas/v1TruckingInfo" },
                  on_carriage: { "$ref" => "#/components/schemas/v1TruckingInfo" }
                }
              }
            }, required: %w[containers_attributes trucking_info]
          },
          v1ShipmentInfoCargoItems: {
            type: :object,
            properties: {
              cargo_items_attributes: {
                type: :array,
                items: { "$ref" => "#/components/schemas/v1CargoItem" }
              },
              trucking_info: {
                type: :object,
                properties: {
                  pre_carriage: { "$ref" => "#/components/schemas/v1TruckingInfo" },
                  on_carriage: { "$ref" => "#/components/schemas/v1TruckingInfo" }
                }
              }
            }, required: %w[cargo_items_attributes trucking_info]
          },
          v1TruckingInfo: {
            type: :object,
            properties: {
              truck_type: {
                type: "string",
                description: "Truck type desired for pre/on carriage"
              }
            },
            nullable: true
          },
          journeyError: {
            type: "object",
            properties: {
              id: {
                description: "ID",
                type: "string"
              },
              code: {
                description: "Code",
                type: "string"
              },
              service: {
                description: "Service",
                type: "string"
              },
              carrier: {
                description: "Carrier",
                type: "string"
              },
              mode_of_transport: {
                description: "MOT",
                type: "string"
              },
              property: {
                description: "Property",
                type: "string"
              },
              value: {
                description: "Value",
                type: "string"
              },
              limit: {
                description: "Limit",
                type: "string"
              }
            }, required: ["id"]
          },
          locationV1Nexus: {
            type: "object",
            properties: {
              nexus_id: {
                type: "integer",
                description: "The unique identifier of the Location Nexus"
              }
            }, required: %w[nexus_id]
          },
          locationV1Trucking: {
            type: "object",
            properties: {
              latitude: {
                type: "string",
                description: "The latitude of the Location"
              },
              longitude: {
                type: "string",
                description: "The longitude of the Location"
              }
            }, required: %w[latitude longitude]
          },
          money: {
            type: "object",
            properties: {
              amount: {
                anyOf: [
                  {
                    type: "string"
                  },
                  {
                    type: "number"
                  }
                ],
                description: "Monetary amount in given currency"
              },
              currency: {
                type: "string",
                description: "ISO 4217 code for currency"
              }
            },
            required: %w[
              amount
              currency
            ]
          },
          v2Money: {
            type: "object",
            properties: {
              value: {
                anyOf: [
                  {
                    type: "string"
                  },
                  {
                    type: "number"
                  }
                ],
                description: "Monetary amount in given currency"
              },
              currency: {
                type: "string",
                description: "ISO 4217 code for currency"
              }
            },
            required: %w[
              value
              currency
            ]
          },
          nexus: {
            type: "object",
            properties: {
              id: {
                description: "ID",
                type: "string"
              },
              type: {
                description: "Type",
                type: "string"
              },
              attributes: {
                description: "Attributes",
                type: "object",
                properties: {
                  id: {
                    description: "ID",
                    type: "number"
                  },
                  name: {
                    description: "Name",
                    type: "string"
                  },
                  locode: {
                    description: "UN/LOCODE",
                    type: "string"
                  },
                  latitude: {
                    description: "Latitude",
                    type: "number"
                  },
                  longitude: {
                    description: "Longitude",
                    type: "number"
                  },
                  modesOfTransport: {
                    description: "MOTs",
                    type: "array",
                    items: {
                      type: "string"
                    }
                  },
                  countryName: {
                    description: "Country Name",
                    type: "string"
                  }
                },
                required: %w[
                  id
                  name
                  latitude
                  longitude
                  locode
                  modesOfTransport
                  countryName
                ]
              }
            },
            required: %w[
              id
              type
              attributes
            ]
          },
          organization: {
            type: "object",
            properties: {
              id: {
                description: "ID",
                type: "string"
              },
              type: {
                description: "Type",
                type: "string"
              },
              attributes: {
                description: "Attributes of the organisation.",
                type: "object",
                properties: {
                  name: {
                    type: "string",
                    description: "Name of the organisation. Usually their legal business name."
                  },
                  slug: {
                    type: "string",
                    description: <<~DOC
                      Short slug of the organisation that is unique for a single
                      organisation. This is usually used as poart of the URL and must
                      always match generic domain requirements.
                    DOC
                  }
                },
                required: %w[name slug]
              }
            },
            required: %w[id type attributes]
          },
          pagination: {
            type: "object",
            properties: {
              page: {
                description: "Current page",
                type: "number"
              },
              perPage: {
                description: "Items per page",
                type: "number"
              },
              totalPages: {
                description: "Total number of pages",
                type: "number"
              }
            },
            required: %w[
              page
              perPage
              totalPages
            ]
          },
          paginationLinks: {
            type: "object",
            properties: {
              first: {
                description: "First page",
                type: "string",
                nullable: true
              },
              prev: {
                description: "Previous page",
                type: "string",
                nullable: true
              },
              next: {
                description: "Next page",
                type: "string",
                nullable: true
              },
              last: {
                description: "Last page",
                type: "string",
                nullable: true
              }
            }
          },
          quotationTender: {
            type: "object",
            properties: {
              data: {
                description: "Data",
                type: "object",
                properties: {
                  id: {
                    description: "ID",
                    type: "string"
                  },
                  type: {
                    description: "Type",
                    type: "string"
                  },
                  attributes: {
                    description: "Attributes",
                    type: "object",
                    properties: {
                      charges: {
                        description: "Charges",
                        type: "array",
                        items: { "$ref": "#/components/schemas/charge" }
                      },
                      route: { description: "Route", type: "string" },
                      vessel: { description: "Vessel", type: "string" },
                      id: { description: "ID", type: "string" },
                      pickupTruckType: { description: "Truck type", type: "string" },
                      deliveryTruckType: { description: "Truck type", type: "string" },
                      pickupCarrier: { description: "Carrier", type: "string" },
                      deliveryCarrier: { description: "Carrier", type: "string" },
                      pickupService: { description: "Service", type: "string" },
                      deliveryService: { description: "Service", type: "string" }
                    }, required: %w[id route]
                  }
                },
                required: %w[id type attributes]
              }
            }
          },
          restfulResponse: {
            type: "object",
            properties: {
              id: {
                description: "ID",
                type: "string"
              }
            }
          },
          result: {
            type: "object",
            properties: {
              id: {
                description: "ID",
                type: "string"
              },
              carrier: {
                description: "Name of the Carrier",
                type: "string"
              },
              modes_of_transport: {
                description: "Main Modes of Transport for the route",
                type: "array",
                items: { type: "string" }
              },
              total: {
                description: "The total value of the Result",
                schema: { "$ref" => "#/components/schemas/money" }
              },
              service_level: {
                description: "Name of the main freight service level",
                type: "string"
              },
              valid_until: {
                description: "Date until which this quote is valid",
                type: "string"
              },
              transit_time: {
                description: "A figure denoting the number of days the journey will likely take",
                type: "integer",
                format: "int32"
              },
              cargo_ready_date: {
                description: "A date and time indicating after which the cargo will be ready for loading",
                type: "string",
                format: "date-time"
              },
              cargo_delivery_date: {
                description: "A date and time indicating by when the cargo needs to be delivered by",
                type: "string",
                format: "date-time"
              },
              origin: {
                description: "The full name of the start point of the quoted journey",
                type: "string"
              },
              destination: {
                description: "The full name of the end point of the quoted journey",
                type: "string"
              },
              origin_terminal: {
                description: "The terminal of the start point of the quoted journey, if the data is present.",
                type: "string",
                nullable: true
              },
              destination_terminal: {
                description: "The terminal of the end point of the quoted journey, if the data is present.",
                type: "string",
                nullable: true
              },
              transshipment: {
                description: "Information regarding the transhipments (if any) that happen during the main section of the journey",
                type: "string"
              },
              numberOfStops: {
                description: "The number of times the cargo will be loaded and unloaded during the journey",
                type: "integer"
              },
              preCarriage: {
                description: "Whether or not the Result includes Pre-carriage of any kind",
                type: "boolean"
              },
              onCarriage: {
                description: "Whether or not the Result includes On-carriage of any kind",
                type: "boolean"
              }
            }
          },
          schedule: {
            type: "object",
            properties: {
              id: {
                description: "ID",
                type: "string"
              },
              estimatedDepartureTime: {
                description: "Estimated departure date",
                type: "datetime"
              },
              estimatedArrivalTime: {
                description: "Estimation of arrival time",
                type: "datetime"
              },
              voyageCode: {
                description: "voyage code",
                type: "string"
              },
              vesselNo: {
                description: "vessel number",
                type: "string"
              },
              closingDate: {
                description: "schedule closing date",
                type: "datetime"
              },
              modeOfTransport: {
                description: "The mode of transport of the schedule",
                type: "string"
              },
              transitTime: {
                description: "The time in days that will take the goods to reach from origin to destination.",
                type: "integer"
              }
            }
          },
          offer: {
            type: "object",
            properties: {
              id: {
                description: "Unique identifier of the Offer",
                type: "string"
              }
            },
            required: ["id"]
          },
          routeSection: {
            type: "object",
            description: "Details regarding the start, end, service and mode of transport of each section of the quoted Journey",
            properties: {
              id: {
                type: "string",
                description: "The ID of the RouteSection"
              },
              service: {
                type: "string",
                description: "The service level of this part of the journey"
              },
              carrier: {
                type: "string",
                description: "The Carrier operating the service on this part of the journey"
              },
              modeOfTransport: {
                type: "string",
                description: "The mode of transport for the section of the journey."
              },
              transitTime: {
                description: "The time in days that this part of the journey will take.",
                type: "integer",
                format: "int32",
                nullable: true
              },
              origin: {
                type: "object",
                description: "The start point of this section",
                properties: { "$ref" => "#/components/schemas/resultDetailedRoutingLocation" }
              },
              destination: {
                type: "object",
                description: "The end point of this section",
                properties: { "$ref" => "#/components/schemas/resultDetailedRoutingLocation" }
              },
              carrierLogo: {
                description: "URL for accesing the logo of the route section's Carrier",
                type: "string",
                nullable: true
              },
              transshipment: {
                description: "Information regarding the transhipments (if any) that happen during this section of the journey",
                type: "string",
                nullable: true
              }
            },
            required: %w[
              id
              service
              carrier
              modeOfTransport
              transitTime
              origin
              destination
              transshipment
            ]
          },
          resultDetailedRoutingLocation: {
            type: "object",
            description: "A object containing the address, locode and city of the location",
            properties: {
              address: {
                type: "string",
                description: "The city name or address of the location"
              },
              locode: {
                type: "string",
                description: "The UN/LOCODE of the location",
                nullable: true
              },
              terminal: {
                type: "string",
                description: "The terminal info of the location, if present",
                nullable: true
              },
              city: {
                type: "string",
                description: "The city name of the location. Will only differ from name if the location is an Address"
              }
            }
          },
          settings: {
            type: "object",
            properties: {
              id: {
                description: "Unique identifier of the settings object",
                type: "string"
              },
              attributes: {
                description: "Attributes",
                type: "object",
                properties: {
                  language: {
                    type: "string",
                    pattern: "[a-z]{2}-[A-Z]{2}",
                    description: <<~DOC
                      User's preferred language. Preferred language is given as language
                      and country combination, allowing different dialects and languages
                      for each region.

                      Language code is combined with language and country, separated by
                      dash. First part of the code, language is the lower-case
                      two-letter codes as defined by ISO-639-1. Second part is the
                      upper-case two-letter codes as defined by ISO-3166-1.

                      For example:

                      * `en-US` - English as spoken in United States of America
                      * `en-GB` - English as spoken in United Kingdom and the Northern Ireland
                      * `sv-FI` - Swedish as spoken in Finland
                    DOC
                  },
                  locale: {
                    type: "string",
                    pattern: "[a-z]{2}-[A-Z]{2}",
                    description: <<~DOC
                      User's preferred locale. Preferred locale defines how numbers and
                      currencies, time et al. are displayed in the shop.

                      Locale code is combined with language and country, separated by
                      dash. First part of the code, language is the lower-case
                      two-letter codes as defined by ISO-639-1. Second part is the
                      upper-case two-letter codes as defined by ISO-3166-1.

                      For example:

                      * `en-US` - English as spoken in United States of America
                      * `en-GB` - English as spoken in United Kingdom and the Northern Ireland
                      * `sv-FI` - Swedish as spoken in Finland
                    DOC
                  }
                }
              }
            }
          },
          scope: {
            type: "object",
            properties: {
              id: {
                description: "Unique identifier of the offer",
                type: "string"
              },
              loginMandatory: {
                type: "boolean",
                description: "This boolean signals whether it is mandatory for a user to log in before they can access the quoting tool itself"
              },
              registrationProhibited: {
                type: "boolean",
                description: "This boolean signals whether it is the case that a user can not register for the quoting tool."
              },
              links: {
                type: "object",
                properties: {
                  legal: {
                    type: "string",
                    description: "Link to any Legal notices the client wants to display",
                    nullable: true
                  },
                  imprint: {
                    type: "string",
                    description: "Link to the 'Imprint' page of the client",
                    nullable: true
                  },
                  about: {
                    type: "string",
                    description: "Link to the About Us page of the Clients website",
                    nullable: true
                  },
                  privacy: {
                    type: "string",
                    description: "Link to the Client's Privacy Policy",
                    nullable: true
                  },
                  terms: {
                    type: "string",
                    description: "Link to the Terms and Conditions the Client operates under",
                    nullable: true
                  }
                }
              },
              authMethods: {
                type: "array",
                description: "This contains the auth methods this Organization accepts",
                schema: "string"
              },
              loginSamlText: {
                type: "string",
                description: "Custom text to be displayed in the 'Log in Via SAML' button"
              }
            }
          },
          user: {
            type: "object",
            properties: {
              id: {
                description: "ID",
                type: "string"
              },
              type: {
                description: "Type",
                type: "string"
              },
              attributes: {
                description: "Attributes",
                type: "object",
                properties: {
                  email: {
                    description: "Email",
                    type: "string"
                  },
                  organizationId: {
                    description: "organization",
                    type: "string"
                  },
                  firstName: {
                    description: "First Name",
                    type: "string"
                  },
                  lastName: {
                    description: "Last Name",
                    type: "string"
                  },
                  phone: {
                    description: "Phone",
                    type: "string",
                    nullable: true
                  },
                  companyName: {
                    description: "Company",
                    type: "string"
                  }
                },
                required: %w[
                  email
                  organizationId
                  firstName
                  lastName
                  phone
                  companyName
                ]
              }
            },
            required: %w[
              id
              type
              attributes
            ]
          },
          v1Client: {
            type: "object",
            properties: {
              id: {
                description: "ID",
                type: "string"
              },
              type: {
                description: "Type",
                type: "string"
              },
              attributes: {
                description: "Attributes",
                type: "object",
                properties: {
                  email: {
                    description: "Email",
                    type: "string"
                  },
                  organizationId: {
                    description: "organization",
                    type: "string"
                  },
                  firstName: {
                    description: "First Name",
                    type: "string"
                  },
                  lastName: {
                    description: "Last Name",
                    type: "string"
                  },
                  phone: {
                    description: "Phone",
                    type: "string",
                    nullable: true
                  },
                  companyName: {
                    description: "The name of the Company the client belongs to",
                    type: "string"
                  },
                  companyId: {
                    description: "The ID of the Company the client belongs to",
                    type: "string"
                  },
                  paymentTerms: {
                    description: "The Payment Terms applicable to the client",
                    type: "string"
                  }
                },
                required: %w[
                  email
                  organizationId
                  firstName
                  lastName
                  phone
                  companyName
                  paymentTerms
                ]
              }
            },
            required: %w[
              id
              type
              attributes
            ]
          },
          v2Client: {
            type: "object",
            properties: {
              id: {
                description: "ID",
                type: "string"
              },
              type: {
                description: "Type",
                type: "string"
              },
              attributes: {
                description: "Attributes",
                type: "object",
                properties: {
                  email: {
                    description: "Email",
                    type: "string"
                  },
                  organizationId: {
                    description: "organization",
                    type: "string"
                  },
                  firstName: {
                    description: "First Name",
                    type: "string"
                  },
                  lastName: {
                    description: "Last Name",
                    type: "string"
                  },
                  phone: {
                    description: "Phone",
                    type: "string",
                    nullable: true
                  },
                  companyName: {
                    description: "The name of the Company the client belongs to",
                    type: "string"
                  },
                  companyId: {
                    description: "The ID of the Company the client belongs to",
                    type: "string"
                  },
                  paymentTerms: {
                    description: "The Payment Terms applicable to the client",
                    type: "string",
                    nullable: true
                  },
                  lastActivityAt: {
                    description: "clients last activity data and time",
                    type: "string",
                    nullable: true
                  }
                }
              }
            }
          },
          profile: {
            type: "object",
            properties: {
              id: {
                description: "Unique identifier of the profile. Format of UUID.",
                type: "string"
              },
              attributes: {
                description: "Attributes",
                type: "object",
                properties: {
                  email: {
                    description: "Email of the client",
                    type: "string"
                  },
                  firstName: {
                    description: "First name of the user. This can be missing in case the user either does not have a first (given) name, or does not want it to be used.",
                    type: "string"
                  },
                  lastName: {
                    description: "User's last or family name. In cases user only has one name, last name is used for identifying that.",
                    type: "string"
                  },
                  phone: {
                    description: "User's phone number for contact purposes",
                    type: "string"
                  },
                  newUser: {
                    description: "A boolean indicating whether the user has even logged in to the application before",
                    type: "boolean"
                  },
                  currency: {
                    description: "The users preferred currency. ISO 4217 3 letter currency code",
                    type: "string"
                  },
                  language: {
                    description: "The Users preferred Language eg. en-US",
                    type: "string"
                  },
                  locale: {
                    description: "The Users preferred Localization eg. en-US",
                    type: "string"
                  }
                },
                required: %w[
                  email
                  firstName
                  lastName
                ]
              }
            },
            required: %w[
              id
              type
              attributes
            ]
          },
          analyticsCount: {
            type: :number,
            nullable: true
          },
          analyticsTotal: {
            type: "object",
            properties: {
              symbol: {
                description: "ISO Currency Code for the Total",
                type: "string"
              },
              value: {
                description: "Value in the base unit (cents) of the Total",
                type: "number"
              }
            }
          },
          analyticsListCount: {
            type: "array",
            items: {
              type: "object",
              properties: {
                label: {
                  description: "Label for displaying the context of the result",
                  type: "string"
                },
                count: {
                  description: "Value of the Analytic result",
                  type: "number"
                }
              }
            }
          }
        },
        securitySchemes: {
          oauth: {
            type: "oauth2",
            description: "This API uses OAuth2 with the password grant flow.",
            flows: {
              password: {
                tokenUrl: "/oauth/tokens",
                refreshUrl: "/oauth/refresh",
                scopes: {
                  public: "Public Access"
                }
              }
            }
          },
          bearerAuth: {
            type: :http,
            description: "Some endpoints authorize via integration token",
            scheme: "bearer"
          }
        }
      },
      servers: [
        {
          url: "https://{host}",
          variables: {
            host: {
              default: "api.itsmycargo.com"
            }
          }
        }
      ]

    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :json

  config.swagger_dry_run = true
  # rubocop:enable Naming/VariableNumber
end
