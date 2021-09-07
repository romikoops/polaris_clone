# frozen_string_literal: true

required "1:1", "A:?", ["CARRIER"]

target_model Routing::Carrier

column "carrier",
  sanitizer: "text",
  validator: "string",
  required: true

add_formatter "Carrier"

model_importer Routing::Carrier
