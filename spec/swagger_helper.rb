# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
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
  config.swagger_root = Rails.root.join("doc", "api").to_s

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
        version: Date.today.to_s
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
        { name: "Users", description: "Users" },
      ],
      components: {
        schemas: {
          errors: {
            type: 'object',
            properties: {
              errors: {
                type: 'object',
                properties: {
                  message: {
                    description: "error message",
                    type: "string"
                  }
                },
                additionalProperties: {
                  type: 'array',
                  items: { type: 'string' }
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
                required: ["width", "length"]
              }
            },
            required: [
              "id",
              "type",
              "attributes"
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
            required: [
              "email",
              "first_name",
              "last_name",
              "company_name",
              "phone",
              "house_number",
              "street",
              "postal_code",
              "country",
              "group_id"
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
              }
            },
            required: [
              "id",
              "lineItemId",
              "tenderId",
              "chargeCategoryId",
              "description",
              "value",
              "originalValue",
              "order",
              "section",
              "level"
            ]
          },
          commodityInfo: {
            type: "object",
            properties: {
              imo_class: {
                type: "string",
                enum: %w[
                  0
                  1.1
                  1.2
                  1.3
                  1.4
                  1.5
                  1.6
                  2.1
                  2.2
                  2.3
                  3
                  4.1
                  4.2
                  4.3
                  5.1
                  5.2
                  6.1
                  6.2
                  7.1
                  7.2
                  7.3
                  7.4
                  8
                  9
                ],
                description: <<~DOC
                  Defines the standard IMO class for the dangerous goods that this cargo item might contain. IMO Class is defined as Class and possible sub-class, where class defines top-level category of type of dangerous goods, and sub-class defines more detailed separation of different dangerous goods.

                  To see list of possible classes and sub-classes, please see for example https://www.searates.com/reference/imo/

                  If dangerous goods category is unknown, please use `0.0` as IMO class, which is used internally for unknown dangerous goods class but known that it is dangerous goods.
                  If cargo item contains no dangerous goods, set this field as `null`.
                DOC
              },
              description: {
                type: "string",
                description: "The description of the IMO Class/ HSCode chosen"
              },
              hs_code: {
                type: "string",
                description: <<~DOC
                  The Harmonized Commodity Description and Coding System, also known as the Harmonized System of tariff nomenclature is an internationally standardized system of names and numbers to classify traded products.
                  This code is is used to identify the type of cargo being shipped as it can affect the pricing and routes available
                DOC

              }
            },
            required: ["id", "code"]
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
                required: [
                  "name",
                  "code",
                  "flag"
                ]
              }
            },
            required: [
              "id",
              "type",
              "attributes"
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
                required: [
                  "id",
                  "name"
                ]
              }
            },
            required: [
              "id",
              "type",
              "attributes"
            ]
          },
          item: {
            type: "object",
            properties: {
              cargo_class: {
                description: "Cargo classification code",
                type: "string",
                enum: [
                  "lcl",
                  "aggregated_lcl",
                  "fcl_10",
                  "fcl_20",
                  "fcl_20_ot",
                  "fcl_20_rf",
                  "fcl_20_frs",
                  "fcl_20_frw",
                  "fcl_40",
                  "fcl_40_hq",
                  "fcl_40_ot",
                  "fcl_40_rf",
                  "fcl_40_hq_rf",
                  "fcl_40_frs",
                  "fcl_40_frw",
                  "fcl_45",
                  "fcl_45_hq",
                  "fcl_45_rf"
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
                type: "number",
                not: 0.0
              },
              width: {
                description: "Width of the item expressed as a decimal on the centimeter (cm) scale",
                type: "number",
                not: 0.0
              },
              height: {
                description: "Height of the item expressed as a decimal on the centimeter (cm) scale",
                type: "number",
                not: 0.0
              },
              weight: {
                description: "Weight of the item expressed as a decimal on the kilogram (kg) scale",
                type: "number",
                not: 0.0
              },
              volume: {
                description: "Volume of the item expressed as a decimal on the cubic meter (m3) scale",
                type: "number",
                not: 0.0
              },
              commodities: {
                description: "Commodity codes of the contents",
                type: "array",
                items: { "$ref": "#/components/schemas/commodityInfo" }
              }
            },
            required: [
              "stackable",
              "colliType",
              "quantity",
              "length",
              "width",
              "height",
              "weight",
              "commodities"
            ],
          },
          item_lcl: {
            type: "object",
            properties: {
              cargo_class: {
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
                enum: [
                  "container",
                  "barrel",
                  "bottle",
                  "carton",
                  "case",
                  "crate",
                  "drum",
                  "package",
                  "pallet",
                  "roll",
                  "skid",
                  "stack",
                  "room_temp_reefer",
                  "low_temp_reefer"
                ]
              },
              quantity: {
                description: "Quantity",
                type: "integer"
              },
              length: {
                description: "Length of the item expressed as a decimal on the centimeter (cm) scale",
                type: "number",
                not: 0.0
              },
              width: {
                description: "Width of the item expressed as a decimal on the centimeter (cm) scale",
                type: "number",
                not: 0.0
              },
              height: {
                description: "Height of the item expressed as a decimal on the centimeter (cm) scale",
                type: "number",
                not: 0.0
              },
              weight: {
                description: "Weight of the item expressed as a decimal on the kilogram (kg) scale",
                type: "number",
                not: 0.0
              },
              volume: {
                description: "Volume is derived from Width, Length and Height values so this property is null",
                type: "number",
                nullable: true
              },
              commodities: {
                description: "Commodity codes of the contents",
                type: "array",
                items: { "$ref": "#/components/schemas/commodityInfo" }
              }
            },
            required: [
              "stackable",
              "colliType",
              "quantity",
              "length",
              "width",
              "height",
              "weight",
              "commodities"
            ],
          },
          item_aggregated_lcl: {
            type: "object",
            properties: {
              cargo_class: {
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
                description: "Quantity",
                type: "integer"
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
                type: "number",
                not: 0.0
              },
              volume: {
                description: "Volume of the item expressed as a decimal on the cubic meter (m3) scale",
                type: "number",
                not: 0.0
              },
              commodities: {
                description: "Commodity codes of the contents",
                type: "array",
                items: { "$ref": "#/components/schemas/commodityInfo" }
              }
            },
            required: [
              "colliType",
              "quantity",
              "volume",
              "weight",
              "commodities",
              "cargo_class"
            ],
          },
          item_fcl: {
            type: "object",
            properties: {
              cargo_class: {
                description: "Container classification code",
                type: "string",
                enum: [
                  "fcl_10",
                  "fcl_20",
                  "fcl_20_ot",
                  "fcl_20_rf",
                  "fcl_20_frs",
                  "fcl_20_frw",
                  "fcl_40",
                  "fcl_40_hq",
                  "fcl_40_ot",
                  "fcl_40_rf",
                  "fcl_40_hq_rf",
                  "fcl_40_frs",
                  "fcl_40_frw",
                  "fcl_45",
                  "fcl_45_hq",
                  "fcl_45_rf"
                ]
              },
              stackable: {
                description: "If cargo item is stackable or not: N/A for FCL",
                type: "boolean"
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
            required: [
              "stackable",
              "colliType",
              "quantity",
              "weight",
              "commodities",
              "cargo_class"
            ],
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
          locationV1: {
            type: "object",
            properties: {
              nexus_id: {
                type: "integer",
                description: "The unique identifier of the Location Nexus"
              },
              latitude: {
                type: "string",
                description: "The latitude of the Location"
              },
              longitude: {
                type: "string",
                description: "The longitude of the Location"
              }
            }, required: ["latitude", "longitude"]
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
            required: [
              "amount",
              "currency"
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
                required: [
                  "id",
                  "name",
                  "latitude",
                  "longitude",
                  "modesOfTransport",
                  "countryName"
                ]
              }
            },
            required: [
              "id",
              "type",
              "attributes"
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
                    description: "Name of the organisation. Usually their legal business name.",
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
            required: [
              "page",
              "perPage",
              "totalPages"
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
                      deliveryService: { description: "Service", type: "string"
                      },
                    }, required: ["id", "route"]
                  }
                },
                required: ["id", "type", "attributes"]
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
          scope: {
            type: "object",
            properties: {
              id: {
                description: "Unique identifier of the offer",
                type: "string"
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
                    type: "string"
                  },
                  companyName: {
                    description: "Company",
                    type: "string"
                  }
                },
                required: [
                  "email",
                  "organizationId",
                  "firstName",
                  "lastName",
                  "phone",
                  "companyName"
                ]
              }
            },
            required: [
              "id",
              "type",
              "attributes"
            ]
          },
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

    },
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :json

  config.swagger_dry_run = true
end
