# frozen_string_literal: true

class ScientistMailerPreview < ActionMailer::Preview
  def successful
    ScientistMailer
      .with(
        experiment_name: "my-experiment",
        app_name: "imc-app",
        has_errors: false,
        query_input_params: query_input_params,
        control_value: nil,
        candidate_value: nil
      )
      .complete_email
  end

  def failed
    ScientistMailer
      .with(
        experiment_name: "my-experiment",
        app_name: "imc-app",
        has_errors: true,
        query_input_params: query_input_params,
        control_value: {
          "order": 2,
          "fee_code": "6",
          "description": "Anti-Terror Compliance",
          "total_cents": 350,
          "total_currency": "EUR",
          "unit_price_cents": 350,
          "unit_price_currency": "EUR",
          "units": 1,
          "wm_rate": "1.0",
          "created_at": "2020-10-27 14:02:45 UTC",
          "updated_at": "2020-10-27 14:02:45 UTC",
          "exchange_rate": "1.0",
          "chargeable_density": "1.0"
        },
        candidate_value: {
          "order": 2,
          "fee_code": "equipment surcharge",
          "description": "EQUIPMENT SURCHARGE",
          "total_cents": 400,
          "total_currency": "USD",
          "unit_price_cents": 400,
          "unit_price_currency": "USD",
          "units": 1,
          "created_at": "2021-05-16 10:12:41 UTC",
          "updated_at": "2021-05-16 10:12:41 UTC",
          "exchange_rate": "0.823323",
          "chargeable_density": "1.03125"
        }
      )
      .complete_email
  end

  private

  def query_input_params
    {
      "selected_day" => "2021-07-30 00:00:00 UTC",
      "cargo_items_attributes" => [],
      "containers_attributes" => [
        {
          "payload_in_kg" => 12_000,
          "size_class" => "fcl_20",
          "quantity" => 1,
          "dangerous_goods" => false
        },
        {
          "payload_in_kg" => 12_000,
          "size_class" => "fcl_40",
          "quantity" => 1,
          "dangerous_goods" => false
        },
        {
          "payload_in_kg" => 12_000,
          "size_class" => "fcl_40_hq",
          "quantity" => 1,
          "dangerous_goods" => false
        }
      ],
      "trucking" => {
        "pre_carriage" => {
          "address_id" => 151,
          "truck_type" => nil
        },
        "on_carriage" => {
          "address_id" => 152,
          "truck_type" => nil
        }
      },
      "origin" => {
        "latitude" => 53.55,
        "longitude" => 9.927,
        "nexus_name" => "Gothenburg",
        "nexus_id" => 75,
        "country" => "SE",
        "full_address" => "Brooktorkai 7,
       Hamburg,
       20457,
       Germany"
      },
      "destination" => {
        "latitude" => 31.232014,
        "longitude" => 121.4867159,
        "nexus_name" => "Shanghai",
        "nexus_id" => 76,
        "country" => "CN",
        "full_address" => "88 Henan Middle Road,
       Shanghai"
      },
      "incoterm" => {},
      "aggregated_cargo_attributes" => [],
      "load_type" => "container"
    }
  end
end
