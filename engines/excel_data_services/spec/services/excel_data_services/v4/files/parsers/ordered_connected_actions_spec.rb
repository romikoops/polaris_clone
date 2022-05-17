# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Parsers::OrderedConnectedActions do
  include_context "V4 setup"

  let(:service) { described_class.new(section: section_string, state: state_arguments) }

  describe "#connected_actions" do
    let(:section_string) { "Hubs" }

    it "returns all ConnectedActions defined in the schema", :aggregate_failures do
      expect(service.connected_actions).to be_all(ExcelDataServices::V4::Files::Parsers::ConnectedActions)
      expect(service.connected_actions.count).to eq(2)
    end
  end
end
