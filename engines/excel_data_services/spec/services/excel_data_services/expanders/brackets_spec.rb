# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Expanders::Brackets do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }
  let(:expanded_table) { result.frame }
  let(:frame) { Rover::DataFrame.new([row]) }

  before do
    Organizations.current_id = organization.id
  end

  describe ".data" do
    context "when it is a numerical range" do
      let(:row) { {bracket: "10 - 20", modifier: "kg"}.stringify_keys }

      it "returns the frame with the tenant_vehicle_id", :aggregate_failures do
        expect(expanded_table.count).to eq(1)
        expect(expanded_table["min"].to_a).to eq([10.0])
        expect(expanded_table["max"].to_a).to eq([20.0])
        expect(expanded_table["modifier"].to_a).to eq(["kg"])
      end
    end
  end
end
