# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Formatters::HubAvailability do
  include_context "V3 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:insertable_data) { result.insertable_data }

  describe "#insertable_data" do
    let(:rows) { FactoryBot.build(:excel_data_services_section_data, :trucking, organization: organization) }
    let(:expected_data) do
      {"hub_id"=>1873, "type_availability_id"=>"6e0434ee-52dc-4e70-a8e1-9f39c67a53c9"}
    end

    it "returns the frame with the insertable_data" do
      expect(insertable_data.to_a.first).to eq(expected_data)
    end
  end
end