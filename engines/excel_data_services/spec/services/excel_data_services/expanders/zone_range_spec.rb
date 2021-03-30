# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Expanders::ZoneRange do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }
  let(:expanded_table) { result.frame }
  let(:frame) { Rover::DataFrame.new([row]) }

  before do
    Organizations.current_id = organization.id
  end

  describe ".data" do
    context "when it is a numerical range" do
      let(:row) { { zone: 1.0, primary: nil, secondary: "10 - 20", country_code: "ZA" }.stringify_keys }

      it "returns the frame with the one row per code in range", :aggregate_failures do
        expect(expanded_table.count).to eq(10)
        expect(expanded_table["primary"].to_a).to eq("10".upto("19").to_a)
      end
    end

    context "when it is an alphanumerical range" do
      let(:row) { { zone: 1.0, primary: nil, secondary: "AB10 - AB20", country_code: "ZA" }.stringify_keys }

      it "returns the frame with the one row per code in range", :aggregate_failures do
        expect(expanded_table.count).to eq(11)
        expect(expanded_table["primary"].to_a).to match_array("AB10".upto("AB20").to_a)
      end
    end
  end
end
