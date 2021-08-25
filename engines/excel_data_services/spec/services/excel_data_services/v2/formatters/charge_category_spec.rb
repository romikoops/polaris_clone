# frozen_string_literal: false

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Formatters::ChargeCategory do
  include_context "for excel_data_services setup"

  describe "#insertable_data" do
    let(:rows) do
      [{
        "fee_code" => "bas",
        "fee_name" => "Basic Freight",
        "row_nr" => 2,
        "organization_id" => organization.id
      },
        {
          "fee_code" => "pff",
          "fee_name" => "Pickup Fee",
          "row_nr" => 3,
          "organization_id" => organization.id
        }]
    end
    let(:expected_data) do
      rows.map do |datum|
        datum.slice("fee_code", "fee_name", "organization_id").transform_keys { |key| key.dup.gsub("fee_", "") }
      end
    end

    let(:service) { described_class.state(state: state_arguments) }

    it "returns the formatted data" do
      expect(service.insertable_data).to match_array(expected_data)
    end
  end
end
