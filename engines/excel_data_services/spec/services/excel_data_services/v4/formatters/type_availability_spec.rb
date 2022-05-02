# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Formatters::TypeAvailability do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:insertable_data) { result.insertable_data }

  describe "#insertable_data" do
    let(:rows) { FactoryBot.build(:excel_data_services_section_data, :trucking, organization: organization) }
    let(:expected_data) do
      { "carriage" => "pre",
        "load_type" => "cargo_item",
        "truck_type" => "default",
        "country_id" => 709,
        "query_method" => 3 }
    end

    it "returns the frame with the insertable_data" do
      expect(insertable_data.to_a.first).to eq(expected_data)
    end
  end
end
