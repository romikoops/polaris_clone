# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::MandatoryCharge do
  include_context "V4 setup"

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
          "row" => 2,
          "organization_id" => organization.id
        }
      end

      it "returns the frame with the mandatory_charge_ids", :aggregate_failures do
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
          "row" => 2,
          "organization_id" => organization.id
        }
      end

      let(:error_messages) do
        config_string = row.slice("export_charges", "import_charges", "pre_carriage", "on_carriage").entries
          .map { |k, v| "#{k}: #{v}" }.join(", ")
        [
          "The Mandatory Charge with '#{config_string}' cannot be found."
        ]
      end

      it "returns no mandatory_charge_ids" do
        expect(extracted_table["mandatory_charge_id"].to_a).to eq([nil])
      end
    end
  end
end
