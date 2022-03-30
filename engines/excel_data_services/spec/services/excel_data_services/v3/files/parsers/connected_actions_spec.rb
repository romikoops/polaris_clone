# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::Parsers::ConnectedActions do
  include_context "V3 setup"

  let(:service) { described_class.new(section: section_string, state: state_arguments) }

  describe "#model" do
    let(:section_string) { "Pricings" }

    it "returns the model defined in the schema" do
      expect(service.model).to eq(Pricings::Pricing)
    end
  end

  describe "#actions" do
    let(:section_string) { "Pricings" }
    let(:service_actions) { service.actions }
    let(:expected_classes) do
      [ExcelDataServices::V3::Validators::SequentialDates,
        ExcelDataServices::V3::Validators::ChargeFees,
        ExcelDataServices::V3::Validators::Carrier,
        ExcelDataServices::V3::Validators::TenantVehicle,
        ExcelDataServices::V3::Validators::OriginHub,
        ExcelDataServices::V3::Validators::DestinationHub,
        ExcelDataServices::V3::Validators::Itinerary,
        ExcelDataServices::V3::Validators::ChargeCategory,
        ExcelDataServices::V3::Validators::Group,
        ExcelDataServices::V3::Validators::RateBasis]
    end

    it "returns the all the validators conflicts extractors, formatters, and the importer defined in the schema" do
      expected_classes.each do |klass|
        expect(service_actions).to include(klass)
      end
    end
  end
end
