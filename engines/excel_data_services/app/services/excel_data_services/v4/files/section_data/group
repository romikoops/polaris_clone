# frozen_string_literal: true

required "1:1", "A:?", %w[GROUP_ID GROUP_NAME]

target_model Groups::Group

column "group_name",
  sanitizer: "text",
  validator: "string",
  required: false
column "group_id",
  sanitizer: "text",
  validator: "uuid"
