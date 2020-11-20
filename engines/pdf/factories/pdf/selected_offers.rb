# frozen_string_literal: true

FactoryBot.define do
  factory :selected_offer, class: "Hash" do
    trip_id { 1234 }

    initialize_with do
      data.deep_dup.merge(trip_id: trip_id).deep_stringify_keys!
    end

    trait :multi_currency do
      data do
        {
          "total": {
            "value": "2719.8", "currency": "USD"
          },
          "edited_total": nil,
          "name": "Grand Total",
          "import": {
            "total": {
              "value": "227.0",
              "currency": "USD"
            },
            "edited_total": nil,
            "name": "Destination Local Charges",
            "21474": {
              "total": {
                "value": "99.0",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Cargoitem",
              "hdl": {
                "value": "90.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Hdl"
              },
              "thc": {
                "value": "9.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Terminal Handling Charge"
              }
            },
            "shipment": {
              "total": {
                "value": "128.0",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Shipment",
              "cfs": {
                "value": "45.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "CFS charge by CBM"
              },
              "doc": {
                "value": "83.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Documentation"
              }
            }
          },
          "export": {
            "total": {
              "value": "2116.63",
              "currency": "USD"
            },
            "edited_total": nil,
            "name": "Origin Local Charges",
            "21474": {
              "total": {
                "value": "1367.03",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Cargoitem",
              "thc": {
                "value": "180.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Terminal Handling Charge"
              },
              "fuel": {
                "value": "1080.0",
                "currency": "EUR",
                "sandbox_id": nil,
                "name": "Fuel Surcharge"
              }
            },
            "shipment": {
              "total": {
                "value": "749.6",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Shipment",
              "doc": {
                "value": "150.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Documentation"
              },
              "haf": {
                "value": "35.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Haf"
              },
              "expc": {
                "value": "70.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Export Customs"
              },
              "scan": {
                "value": "450.0",
                "currency": "EUR",
                "sandbox_id": nil,
                "name": "Scan"
              }
            }
          },
          "trucking_pre": {
            "total": {
              "value": "194.86",
              "currency": "USD"
            },
            "edited_total": nil,
            "name": "Inland haulage fees",
            "trucking_lcl": {
              "total": {
                "value": "194.86",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Trucking LCL",
              "stackable": {
                "value": "194.86",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "stackable"
              }
            }
          },
          "trucking_on": {
            "total": {
              "value": "113.31",
              "currency": "USD"
            },
            "edited_total": nil,
            "name": "Inland haulage fees",
            "trucking_lcl": {
              "total": {
                "value": "810.0",
                "currency": "CNY"
              },
              "edited_total": nil,
              "name": "Trucking LCL",
              "stackable": {
                "value": "810.0",
                "currency": "CNY",
                "sandbox_id": nil,
                "name": "stackable"
              }
            }
          },
          "cargo": {
            "total": {
              "value": "0.0",
              "currency": "USD"
            },
            "edited_total": nil,
            "name": "Freight",
            "21474": {
              "total": {
                "value": "0.0",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Cargoitem",
              "bas": {
                "value": "0.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Basic Ocean Freight"
              }
            }
          },
          "valid_until": 30.days.from_now.beginning_of_day
        }
      end
    end

    trait :single_currency do
      data do
        {
          "total": {
            "value": "2719.8", "currency": "USD"
          },
          "edited_total": nil,
          "name": "Grand Total",
          "import": {
            "total": {
              "value": "227.0",
              "currency": "USD"
            },
            "edited_total": nil,
            "name": "Destination Local Charges",
            "21474": {
              "total": {
                "value": "99.0",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Cargoitem",
              "hdl": {
                "value": "90.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Hdl"
              },
              "thc": {
                "value": "9.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Terminal Handling Charge"
              }
            },
            "shipment": {
              "total": {
                "value": "128.0",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Shipment",
              "cfs": {
                "value": "45.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "CFS charge by CBM"
              },
              "doc": {
                "value": "83.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Documentation"
              }
            }
          },
          "export": {
            "total": {
              "value": "2116.63",
              "currency": "USD"
            },
            "edited_total": nil,
            "name": "Origin Local Charges",
            "21474": {
              "total": {
                "value": "1367.03",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Cargoitem",
              "thc": {
                "value": "180.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Terminal Handling Charge"
              },
              "fuel": {
                "value": "1080.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Fuel Surcharge"
              }
            },
            "shipment": {
              "total": {
                "value": "749.6",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Shipment",
              "doc": {
                "value": "150.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Documentation"
              },
              "haf": {
                "value": "35.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Haf"
              },
              "expc": {
                "value": "70.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Export Customs"
              },
              "scan": {
                "value": "450.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Scan"
              }
            }
          },
          "trucking_pre": {
            "total": {
              "value": "194.86",
              "currency": "USD"
            },
            "edited_total": nil,
            "name": "Inland haulage fees",
            "trucking_lcl": {
              "total": {
                "value": "194.86",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Trucking LCL",
              "stackable": {
                "value": "194.86",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "stackable"
              }
            }
          },
          "trucking_on": {
            "total": {
              "value": "113.31",
              "currency": "USD"
            },
            "edited_total": nil,
            "name": "Inland haulage fees",
            "trucking_lcl": {
              "total": {
                "value": "113.31",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Trucking LCL",
              "stackable": {
                "value": "113.31",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "stackable"
              }
            }
          },
          "cargo": {
            "total": {
              "value": "100.0",
              "currency": "USD"
            },
            "edited_total": nil,
            "name": "Freight",
            "21474": {
              "total": {
                "value": "100.0",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Cargoitem",
              "bas": {
                "value": "100.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Basic Ocean Freight"
              }
            }
          },
          "valid_until": 30.days.from_now.beginning_of_day
        }
      end
    end

    trait :consolidated do
      data do
        {
          "total": {
            "value": "2719.8", "currency": "USD"
          },
          "edited_total": nil,
          "name": "Grand Total",
          "import": {
            "total": {
              "value": "227.0",
              "currency": "USD"
            },
            "edited_total": nil,
            "name": "Destination Local Charges",
            "cargo_item": {
              "total": {
                "value": "99.0",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Cargoitem",
              "hdl": {
                "value": "90.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Hdl"
              },
              "thc": {
                "value": "9.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Terminal Handling Charge"
              }
            },
            "shipment": {
              "total": {
                "value": "128.0",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Shipment",
              "cfs": {
                "value": "45.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "CFS charge by CBM"
              },
              "doc": {
                "value": "83.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Documentation"
              }
            }
          },
          "export": {
            "total": {
              "value": "2116.63",
              "currency": "USD"
            },
            "edited_total": nil,
            "name": "Origin Local Charges",
            "cargo_item": {
              "total": {
                "value": "1367.03",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Cargoitem",
              "thc": {
                "value": "180.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Terminal Handling Charge"
              },
              "fuel": {
                "value": "1080.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Fuel Surcharge"
              }
            },
            "shipment": {
              "total": {
                "value": "749.6",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Shipment",
              "doc": {
                "value": "150.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Documentation"
              },
              "haf": {
                "value": "35.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Haf"
              },
              "expc": {
                "value": "70.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Export Customs"
              },
              "scan": {
                "value": "450.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Scan"
              }
            }
          },
          "trucking_pre": {
            "total": {
              "value": "194.86",
              "currency": "USD"
            },
            "edited_total": nil,
            "name": "Inland haulage fees",
            "trucking_lcl": {
              "total": {
                "value": "194.86",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Trucking LCL",
              "stackable": {
                "value": "194.86",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "stackable"
              }
            }
          },
          "trucking_on": {
            "total": {
              "value": "113.31",
              "currency": "USD"
            },
            "edited_total": nil,
            "name": "Inland haulage fees",
            "trucking_lcl": {
              "total": {
                "value": "113.31",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Trucking LCL",
              "stackable": {
                "value": "113.31",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "stackable"
              }
            }
          },
          "cargo": {
            "total": {
              "value": "100.0",
              "currency": "USD"
            },
            "edited_total": nil,
            "name": "Freight",
            "cargo_item": {
              "total": {
                "value": "100.0",
                "currency": "USD"
              },
              "edited_total": nil,
              "name": "Cargoitem",
              "bas": {
                "value": "100.0",
                "currency": "USD",
                "sandbox_id": nil,
                "name": "Basic Ocean Freight"
              }
            }
          },
          "valid_until": 30.days.from_now.beginning_of_day
        }
      end
    end

    factory :single_currency_selected_offer, traits: [:single_currency]
    factory :multi_currency_selected_offer, traits: [:multi_currency]
    factory :consolidated_selected_offer, traits: [:consolidated]
  end
end
