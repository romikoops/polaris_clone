# frozen_string_literal: true

RSpec.shared_context "journey_complete_request" do
  include_context "journey_query"
  include_context "journey_cargo_units"
  include_context "journey_result"
  include_context "journey_line_services"
  include_context "with routing_line_sections"
  include_context "journey_line_items"
  include_context "journey_pricing_metadatum"
end
