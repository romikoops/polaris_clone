# frozen_string_literal: true

required "1:1", "A:?", %w[MOT CARRIER SERVICE_LEVEL]

column "service",
  sanitizer: "text",
  validator: "string",
  required: true,
  type: :object,
  alternative_keys: ["service_level"],
  fallback: "standard"
column "carrier",
  sanitizer: "text",
  validator: "string",
  required: true,
  type: :object,
  fallback: organization.slug
column "mode_of_transport",
  sanitizer: "text",
  validator: "mode_of_transport",
  required: true,
  type: :object,
  alternative_keys: ["mot"]

prerequisite "Carrier"

add_extractor "Carrier"
add_formatter "TenantVehicle"

model_importer Legacy::TenantVehicle
target_model Legacy::TenantVehicle
