# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::SheetParser do
  include_context "V4 setup"

  let(:xlsx) { File.open(file_fixture("excel/example_trucking.xlsx")) }
  let(:service) { described_class.new(section: section_string, state: state_arguments) }
  let(:section_string) { "Truckings" }

  describe "#pipelines" do
    it "returns the section in order of dependecy" do
      expect(service.pipelines).to eq(%w[Truckings])
    end
  end
end
