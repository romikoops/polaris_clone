# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Validators::Language do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }

  describe ".state" do
    context "when matched" do
      let(:row) do
        {
          "row" => 2,
          "language" => "en-US",
          "organization_id" => organization.id
        }
      end

      it "returns the frame with the language" do
        expect(extracted_table["language"].to_a).to eq(["en-US"])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "language" => "en-FOO",
          "row" => 3,
          "organization_id" => organization.id
        }
      end

      let(:error_messages) do
        ["The language 'en-FOO' is not one of en-US, de-DE, es-ES"]
      end

      it "appends an error to the state", :aggregate_failures do
        expect(result.errors).to be_present
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
