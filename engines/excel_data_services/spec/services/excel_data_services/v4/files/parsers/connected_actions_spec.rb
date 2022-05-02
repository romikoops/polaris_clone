# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Parsers::ConnectedActions do
  include_context "V4 setup"

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
      [ExcelDataServices::V4::Validators::SequentialDates,
        ExcelDataServices::V4::Validators::ChargeFees,
        ExcelDataServices::V4::Validators::Carrier,
        ExcelDataServices::V4::Validators::TenantVehicle,
        ExcelDataServices::V4::Validators::OriginHub,
        ExcelDataServices::V4::Validators::DestinationHub,
        ExcelDataServices::V4::Validators::Itinerary,
        ExcelDataServices::V4::Validators::ChargeCategory,
        ExcelDataServices::V4::Validators::Group,
        ExcelDataServices::V4::Validators::RateBasis]
    end

    it "returns the all the validators conflicts extractors, formatters, and the importer defined in the schema" do
      expected_classes.each do |klass|
        expect(service_actions).to include(klass)
      end
    end
  end
end
