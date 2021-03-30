# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Importers::Base do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:data) do
    Rover::DataFrame.new([])
  end
  let(:options) { { organization: organization, data: data, options: {} } }
  let(:importer) { described_class.new(data: data, type: "hub_availabilities") }

  describe ".options" do
    it "raises a Not Implemented error" do
      expect { importer.send(:options) }.to raise_error(NotImplementedError)
    end
  end
end
