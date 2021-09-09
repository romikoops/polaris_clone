# frozen_string_literal: true

required "1:1", "A:?", ["CARRIER"]

target_model Legacy::Carrier

column "carrier",
  sanitizer: "text",
  validator: "string",
  required: true
column "carrier_code",
  sanitizer: "downcase",
  validator: "string",
  required: false,
  alternative_keys: ["carrier"]

prerequisite "RoutingCarrier"

add_formatter "Carrier"
model_importer Legacy::Carrier
