# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Validators::MandatoryCharge do
  include_context "for excel_data_services setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:mandatory_charge) { factory_mandatory_charge }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "export_charges" => false,
          "import_charges" => false,
          "pre_carriage" => false,
          "on_carriage" => false,
          "row" => 2
        }
      end

      it "returns the frame with the mandatory_charge_id", :aggregate_failures do
        expect(extracted_table["mandatory_charge_id"].to_a).to eq([mandatory_charge.id])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "export_charges" => false,
          "import_charges" => true,
          "pre_carriage" => false,
          "on_carriage" => true,
          "row" => 2
        }
      end

      let(:error_messages) do
        ["The Mandatory Charge with 'export_charges: false, import_charges: true, pre_carriage: false, on_carriage: true' cannot be found."]
      end

      it "appends an error to the state" do
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
