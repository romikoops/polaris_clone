# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Restructurers::ScheduleGenerator do
  describe ".restructure" do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:data) { FactoryBot.build(:schedule_generator_data).first }

    it "extracts the row data from the sheet hash" do
      result = described_class.restructure(organization: organization, data: data)
      result = result["ScheduleGenerator"]
      aggregate_failures do
        expect(result.length).to be(4)
        expect(result.first[:ordinals].length).to be(1)
        expect(result.first[:ordinals].first).to be(4)
        expect(result.first[:cargo_class]).to be("container")
      end
    end
  end
end
