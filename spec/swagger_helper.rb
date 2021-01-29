# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join("doc", "swagger").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    "v1/swagger.json" => {
      openapi: "3.0.1",
      info: {
        title: "API",
        termsOfService: "https://www.itsmycargo.com/terms",
        contact: {
          name: "API Support",
          url: "https://support.itsmycargo.com",
          email: "support@itsmycargo.com"
        },
        version: "v1"
      },
      components: {
        schemas: {
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
                description: "Descriptive attributes of the cargo item",
                type: "object",
                properties: {
                  width: {
                    description: "Width of the given cargo item type",
                    type: "string"
                  },
                  length: {
                    description: "Length of the given cargo item type",
                    type: "string"
                  },
                  description: {
                    description: "Descriptive information of the cargo item type",
                    type: "string"
                  }
                },
                required: [
                  "width",
                  "length",
                  "description"
                ]
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
                type: "string"
              },
              lineItemId: {
                type: "string"
              },
              tenderId: {
                type: "string"
              },
              chargeCategoryId: {
                type: "integer"
              },
              description: {
                type: "string"
              },
              value: {
                "$ref": "#/components/schemas/money"
              },
              originalValue: {
                "$ref": "#/components/schemas/money"
              },
              order: {
                type: "integer"
              },
              section: {
                type: "string"
              },
              level: {
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
          country: {
            type: "object",
            properties: {
              id: {
                type: "string"
              },
              type: {
                type: "string"
              },
              attributes: {
                type: "object",
                properties: {
                  name: {
                    type: "string"
                  },
                  code: {
                    type: "string"
                  },
                  flag: {
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
                type: "string"
              },
              type: {
                type: "string"
              },
              attributes: {
                type: "object",
                properties: {
                  id: {
                    type: "string"
                  },
                  name: {
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
                type: "string"
              },
              type: {
                type: "nexus"
              },
              attributes: {
                type: "object",
                properties: {
                  id: {
                    type: "number"
                  },
                  name: {
                    type: "string"
                  },
                  latitude: {
                    type: "number"
                  },
                  longitude: {
                    type: "number"
                  },
                  modesOfTransport: {
                    type: "array",
                    items: {
                      type: "string"
                    }
                  },
                  countryName: {
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
                type: "string"
              },
              type: {
                type: "string"
              },
              attributes: {
                type: "object",
                properties: {
                  slug: {
                    type: "string"
                  }
                },
                required: [
                  "slug"
                ]
              }
            },
            required: [
              "id",
              "type",
              "attributes"
            ]
          },
          user: {
            type: "object",
            properties: {
              id: {
                type: "string"
              },
              type: {
                type: "string"
              },
              attributes: {
                type: "object",
                properties: {
                  email: {
                    type: "string"
                  },
                  organizationId: {
                    type: "string"
                  },
                  firstName: {
                    type: "string"
                  },
                  lastName: {
                    type: "string"
                  },
                  phone: {
                    type: "string"
                  },
                  companyName: {
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
          pagination: {
            type: "object",
            properties: {
              page: {
                type: "number"
              },
              perPage: {
                type: "number"
              },
              totalPages: {
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
                type: "string",
                nullable: true
              },
              prev: {
                type: "string",
                nullable: true
              },
              next: {
                type: "string",
                nullable: true
              },
              last: {
                type: "string",
                nullable: true
              }
            }
          },
          quotationTender: {
            type: "object",
            properties: {
              data: {
                type: "object",
                properties: {
                  id: {
                    type: "string"
                  },
                  type: {
                    type: "string"
                  },
                  attributes: {
                    type: "object",
                    properties: {
                      charges: {
                        type: "array",
                        items: {
                          "$ref": "#/components/schemas/charge"
                        }
                      },
                      route: {
                        type: "string"
                      },
                      vessel: {
                        type: "string"
                      },
                      id: {
                        type: "string"
                      },
                      pickupTruckType: {
                        type: "string"
                      },
                      deliveryTruckType: {
                        type: "string"
                      },
                      pickupCarrier: {
                        type: "string"
                      },
                      deliveryCarrier: {
                        type: "string"
                      },
                      pickupService: {
                        type: "string"
                      },
                      deliveryService: {
                        type: "string"
                      },
                      required: [
                        "id",
                        "route"
                      ]
                    }
                  }
                },
                required: [
                  "id",
                  "route"
                ]
              }
            }
          },
          widget: {
            type: "object",
            properties: {
              id: {
                type: "string"
              },
              organizationId: {
                type: "string"
              },
              data: {
                type: "string"
              },
              name: {
                type: "string"
              },
              order: {
                type: "number"
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
    "v2/swagger.json" => {
      openapi: "3.0.1",
      info: {
        title: "API",
        termsOfService: "https://www.itsmycargo.com/terms",
        contact: {
          name: "API Support",
          url: "https://support.itsmycargo.com",
          email: "support@itsmycargo.com"
        },
        version: "v2"
      },
      paths: {
        "/v2/organizations/{organization_id}/queries": {
          post: {
            tags: ["Query"],
            security: [oauth: []],
            consumes: "application/json",
            produces: "application/json",
            parameters: [
              {
                name: "organization_id",
                in: "path",
                type: "string",
                description: "The current organization ID"
              }
            ]
          }
        }
      },
      components: {
        schemas: {
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
          journeyError: {
            type: "object",
            properties: {
              id: {
                type: "string"
              },
              code: {
                type: "string"
              },
              service: {
                type: "string"
              },
              carrier: {
                type: "string"
              },
              mode_of_transport: {
                type: "string"
              },
              property: {
                type: "string"
              },
              value: {
                type: "string"
              },
              limit: {
                type: "string"
              }
            }
          },
          item: {
            type: "object",
            properties: {
              stackable: {
                type: "boolean"
              },
              valid: {
                type: "boolean"
              },
              dangerous: {
                type: "boolean"
              },
              cargoItemTypeId: {
                type: "string"
              },
              quantity: {
                type: "integer"
              },
              length: {
                type: "integer"
              },
              width: {
                type: "integer"
              },
              height: {
                type: "integer"
              },
              weight: {
                type: "integer"
              },
              commodityCodes: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    id: {
                      type: "string"
                    },
                    code: {
                      type: "string"
                    }
                  }
                }
              }
            }
          },
          resultSet: {
            type: "object",
            properties: {
              id: {
                type: "string"
              },
              currency: {
                type: "string"
              },
              status: {
                type: "string"
              }
            }
          },
          restfulResponse: {
            type: "object",
            properties: {
              id: {
                type: "string"
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
end
