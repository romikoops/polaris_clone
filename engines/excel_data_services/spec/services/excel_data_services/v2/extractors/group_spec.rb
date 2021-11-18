# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Extractors::Group do
  include_context "for excel_data_services setup"
  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:group) { FactoryBot.create(:groups_group, organization: organization) }

  describe ".state" do
    context "when found" do
      let(:rows) do
        [
          {
            "group_id" => group.id,
            "group_name" => group.name,
            "row" => 2
          },
          {
            "group_id" => group.id,
            "group_name" => nil,
            "row" => 3
          },
          {
            "group_id" => nil,
            "group_name" => group.name,
            "row" => 4
          },
          {
            "group_id" => nil,
            "group_name" => nil,
            "row" => 4
          }
        ]
      end

      it "returns the frame with the group_id" do
        expect(extracted_table["group_id"].to_a).to match_array([group.id, group.id, group.id, default_group.id])
      end
    end

    context "when not found" do
      let(:rows) do
        [{
          "group_name" => "AAA",
          "group_id" => nil,
          "row" => 2
        }]
      end

      it "does not find the record or add a group_id" do
        expect(extracted_table["group_id"].to_a).to eq([nil])
      end
    end
  end
end
