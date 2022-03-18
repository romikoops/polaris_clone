# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::Parsers::OrderedConnectedActions do
  include_context "V3 setup"

  let(:service) { described_class.new(section: section_string, state: state_arguments) }

  describe "#connected_actions" do
    let(:section_string) { "TenantVehicle" }

    it "returns all ConnectedActions defined in the schema", :aggregate_failures do
      expect(service.connected_actions).to be_all(ExcelDataServices::V3::Files::Parsers::ConnectedActions)
      expect(service.connected_actions.map(&:section)).to eq(%w[RoutingCarrier Carrier TenantVehicle])
    end

    context "when there are prerequisite connected_actions" do
      let(:section_string) { "RoutingCarrier" }

      it "returns the defined prerequisites" do
        expect(service.connected_actions.map(&:section)).to eq(["RoutingCarrier"])
      end
    end
  end
end
