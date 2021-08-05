# frozen_string_literal: true

RSpec.shared_context "journey_line_services" do
  let(:pre_carriage_carrier) { carriage_routing_carrier.name }
  let(:freight_carriage_carrier) { freight_carriage_routing_carrier.name }
  let(:on_carriage_carrier) { carriage_routing_carrier.name }
  let(:pre_carriage_service) { "standard" }
  let(:freight_carriage_service) { "standard" }
  let(:on_carriage_service) { "standard" }
  let(:carriage_routing_carrier) { FactoryBot.create(:routing_carrier, name: "SACO", code: "saco") }
  let(:freight_carriage_routing_carrier) { FactoryBot.create(:routing_carrier, name: "MSC", code: "msc") }
end
