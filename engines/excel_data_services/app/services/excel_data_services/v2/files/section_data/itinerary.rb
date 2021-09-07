# frozen_string_literal: true

required "1:1", "A:?", %w[MOT ORIGIN_LOCODE DESTINATION_LOCODE]

column "origin_locode",
  sanitizer: "text",
  validator: "optional_locode",
  required: false,
  type: :object
column "origin_terminal",
  sanitizer: "text",
  validator: "optional_string",
  required: false,
  type: :object
column "origin",
  sanitizer: "text",
  validator: "optional_string",
  required: false,
  type: :object
column "country_origin",
  sanitizer: "text",
  validator: "optional_string",
  required: false,
  type: :object
column "destination_locode",
  sanitizer: "text",
  validator: "optional_locode",
  required: false,
  type: :object
column "destination_terminal",
  sanitizer: "text",
  validator: "optional_string",
  required: false,
  type: :object
column "destination",
  sanitizer: "text",
  validator: "optional_string",
  required: false,
  type: :object
column "country_destination",
  sanitizer: "text",
  validator: "optional_string",
  required: false,
  type: :object
column "mode_of_transport",
  sanitizer: "text",
  validator: "string",
  required: false,
  alternative_keys: ["mot"],
  type: :object
column "transshipment",
  sanitizer: "text",
  validator: "optional_string",
  required: false,
  type: :object

add_extractor "RouteHubs"
add_formatter "Itinerary"

model_importer Legacy::Itinerary
target_model Legacy::Itinerary
