# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Parsers::ConnectedActions do
  include_context "V4 setup"

  let(:service) { described_class.new(schema_data: schema_data, state: state_arguments) }

  describe "#actions" do
    let(:schema_data) do
      {
        validators: %w[QueryMethod],
        extractors: %w[Carriage],
        formatter: "TypeAvailability",
        importer: { model: "Trucking::TypeAvailability", options: { validate: false } }
      }
    end
    let(:service_actions) { service.actions }

    expected_actions = [
      ExcelDataServices::V4::Validators::QueryMethod,
      ExcelDataServices::V4::Extractors::Carriage,
      ExcelDataServices::V4::Formatters::TypeAvailability
    ]

    it "returns the all the validators conflicts extractors, formatters, and the importer defined in the schema" do
      expect(service_actions[0..2]).to eq(expected_actions)
      expect(service_actions[3]).to be_a(ExcelDataServices::V4::Files::Importer)
    end
  end
end
