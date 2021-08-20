# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Extractors::MandatoryCharge do
  include_context "for excel_data_services extractor setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:mandatory_charge) { FactoryBot.create(:legacy_mandatory_charge) }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "export_charges" => mandatory_charge.export_charges,
          "import_charges" => mandatory_charge.import_charges,
          "pre_carriage" => mandatory_charge.pre_carriage,
          "on_carriage" => mandatory_charge.on_carriage,
          "row" => 2
        }
      end

      it "returns the frame with the mandatory_charge_id" do
        expect(extracted_table["mandatory_charge_id"].to_a).to eq([mandatory_charge.id])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "export_charges" => !mandatory_charge.export_charges,
          "import_charges" => !mandatory_charge.import_charges,
          "pre_carriage" => !mandatory_charge.pre_carriage,
          "on_carriage" => !mandatory_charge.on_carriage,
          "row" => 2
        }
      end

      let(:error_messages) do
        config_string = row.slice("export_charges", "import_charges", "pre_carriage", "on_carriage").entries
          .map { |k, v| "#{k.upcase}: #{v}" }.join(", ")
        [
          "The Mandatory Charge with '#{config_string}' cannot be found."
        ]
      end

      it "appends an error to the state", :aggregate_failures do
        expect(result).to be_failed
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
