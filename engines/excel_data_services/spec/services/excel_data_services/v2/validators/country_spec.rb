# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Validators::Country do
  include_context "for excel_data_services setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:country) { FactoryBot.create(:legacy_country) }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "country" => country.name,
          "row" => 2,
          "country_id" => nil
        }
      end

      it "returns the frame with the country_id" do
        expect(extracted_table["country_id"].to_a).to eq([country.id])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "country" => "AAA",
          "row" => 2,
          "country_id" => nil
        }
      end

      let(:error_messages) do
        ["The country '#{row.values_at('country', 'country_code').compact.join(' ')}' cannot be found."]
      end

      it "appends an error to the state", :aggregate_failures do
        expect(result.errors).to be_present
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
