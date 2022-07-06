# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Parsers::ConnectedActions do
  include_context "V4 setup"

  let(:service) { described_class.new(schema_data: schema_data, state: state_arguments) }

  describe "#actions" do
    let(:schema_data) do
      {
        validators: [{ type: "QueryMethod", frames: ["zones"] }],
        extractors: [{ type: "Carriage" }],
        formatter: "TypeAvailability",
        importer: { model: "Trucking::TypeAvailability", options: { validate: false } }
      }
    end
    let(:service_actions) { service.actions }

    expected_wrapped_actions = [
      ExcelDataServices::V4::Validators::QueryMethod,
      ExcelDataServices::V4::Extractors::Carriage
    ]

    it "returns the all the validators conflicts extractors, formatters, and the importer defined in the schema", :aggregate_failures do
      expect(service_actions[0..1].map(&:action)).to match_array(expected_wrapped_actions)
      expect(service_actions[0..1].map(&:target_frame)).to match_array(%w[zones default])
      expect(service_actions[2]).to eq(ExcelDataServices::V4::Formatters::TypeAvailability)
      expect(service_actions[3]).to be_a(ExcelDataServices::V4::Files::Importer)
    end
  end
end
