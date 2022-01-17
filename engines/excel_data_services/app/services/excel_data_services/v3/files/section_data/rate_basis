# frozen_string_literal: true

required "1:1", "A:?", ["RATE_BASIS"]

target_model Pricings::RateBasis

column "rate_basis",
  sanitizer: "text",
  validator: "rate_basis",
  required: false,
  type: :object
