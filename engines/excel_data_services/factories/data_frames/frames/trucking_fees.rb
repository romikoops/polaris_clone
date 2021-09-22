# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_fees_frame, class: "Rover::DataFrame" do
    transient do
      fees { [] }
      sheet_name { "Fees" }
      carrier { "SACO" }
      service { "standard" }
      organization { FactoryBot.create(:organizations_organization) }
    end
    initialize_with do
      new(fees, types: ExcelDataServices::DataFrames::DataProviders::Trucking::Fees.column_types)
    end

    trait :no_fees do
      transient do
        fees do
          {
            "fee" => [],
            "mot" => [],
            "fee_code" => [],
            "truck_type" => [],
            "direction" => [],
            "currency" => [],
            "rate_basis" => [],
            "ton" => [],
            "cbm" => [],
            "kg" => [],
            "item" => [],
            "shipment" => [],
            "bill" => [],
            "container" => [],
            "minimum" => [],
            "wm" => [],
            "percentage" => [],
            "sheet_name" => [],
            "carrier" => [],
            "service" => [],
            "cargo_class" => [],
            "zone" => [],
            "organization_id" => []
          }
        end
      end
    end

    trait :fees do
      transient do
        fees do
          [
            {
              "fee" => "Fuel Surcharge",
              "mot" => "truck_carriage",
              "fee_code" => "FSC",
              "truck_type" => "default",
              "direction" => "export",
              "currency" => "EUR",
              "rate_basis" => "PER_SHIPMENT",
              "ton" => nil,
              "cbm" => nil,
              "kg" => nil,
              "item" => nil,
              "shipment" => 120.0,
              "bill" => nil,
              "container" => nil,
              "minimum" => nil,
              "wm" => nil,
              "percentage" => nil,
              "sheet_name" => sheet_name,
              "carrier" => nil,
              "service" => nil,
              "cargo_class" => nil,
              "zone" => nil,
              "organization_id" => organization.id
            }
          ]
        end
      end
    end

    trait :invalid do
      transient do
        fees do
          [
            {
              "fee" => nil,
              "mot" => "horseback",
              "fee_code" => nil,
              "truck_type" => "tonka",
              "direction" => "export",
              "currency" => "monopoly",
              "rate_basis" => "/SHIPMENT",
              "ton" => nil,
              "cbm" => nil,
              "kg" => nil,
              "item" => nil,
              "shipment" => nil,
              "bill" => nil,
              "container" => nil,
              "minimum" => nil,
              "wm" => nil,
              "percentage" => nil,
              "sheet_name" => sheet_name,
              "carrier" => nil,
              "service" => nil,
              "cargo_class" => nil,
              "zone" => nil,
              "organization_id" => organization.id
            }
          ]
        end
      end
    end

    trait :with_all_options_set do
      transient do
        fees do
          [
            {
              "fee" => "Fuel Surcharge",
              "mot" => "truck_carriage",
              "fee_code" => "FSC",
              "truck_type" => "default",
              "direction" => "export",
              "currency" => "EUR",
              "rate_basis" => "PER_SHIPMENT",
              "ton" => nil,
              "cbm" => nil,
              "kg" => nil,
              "item" => nil,
              "shipment" => 100.0,
              "bill" => nil,
              "container" => nil,
              "minimum" => nil,
              "wm" => nil,
              "percentage" => nil,
              "sheet_name" => sheet_name,
              "carrier" => carrier,
              "service" => service,
              "cargo_class" => "lcl",
              "zone" => 1.0,
              "organization_id" => organization.id
            }
          ]
        end
      end
    end
  end
end
