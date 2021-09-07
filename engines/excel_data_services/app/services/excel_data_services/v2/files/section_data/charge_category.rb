# frozen_string_literal: true

target_model Legacy::ChargeCategory

column "fee_name",
  sanitizer: "text",
  validator: "string",
  required: false
column "fee_code",
  sanitizer: "downcase",
  validator: "string",
  required: false,
  alternative_keys: ["code"]

add_dynamic_columns excluding: %w[GROUP_ID GROUP_NAME EFFECTIVE_DATE EXPIRATION_DATE COUNTRY_ORIGIN ORIGIN ORIGIN_LOCODE COUNTRY_DESTINATION MOT DESTINATION DESTINATION_LOCODE TRANSSHIPMENT TRANSIT_TIME CARRIER SERVICE_LEVEL LOAD_TYPE CURRENCY RATE_BASIS FEE_CODE FEE_NAME FEE_MIN FEE WM_RATIO VM_RATIO RANGE_MAX RANGE_MIN REMARKS]
add_operation "DynamicFees"
add_formatter "ChargeCategory"

model_importer Legacy::ChargeCategory
