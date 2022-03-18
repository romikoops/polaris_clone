# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::Parsers::Framer do
  include_context "V3 setup"

  let(:service) { described_class.new(section: section_string, state: state_arguments) }

  describe "#framer" do
    let(:section_string) { "Truckings" }

    it "returns the Framer defined in the schema" do
      expect(service.framer).to eq(ExcelDataServices::V3::Framers::TruckingRates)
    end

    context "when there are no Framer defined" do
      let(:section_string) { "Schedules" }

      it "returns the default Framer class" do
        expect(service.framer).to eq(ExcelDataServices::V3::Framers::Table)
      end
    end
  end
end
