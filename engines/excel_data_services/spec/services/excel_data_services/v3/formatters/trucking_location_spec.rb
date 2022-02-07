# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Formatters::TruckingLocation do
  include_context "V3 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:insertable_data) { result.insertable_data }

  describe "#insertable_data" do
    context "when found" do
      let(:rows) { FactoryBot.build(:excel_data_services_section_data, :trucking, organization: organization) }
      let(:expected_data) do
        {"country_id"=>709,
          "location_id"=>"f8fde297-b404-4f8c-9d17-7f0161948aea",
          "data"=>"20038",
          "query"=>1}
      end

      it "returns the frame with the insertable_data" do
        expect(insertable_data.to_a.first).to eq(expected_data)
      end
    end
  end
end
