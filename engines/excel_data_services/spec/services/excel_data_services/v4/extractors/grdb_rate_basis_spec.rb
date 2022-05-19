# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::GrdbRateBasis do
  include_context "V4 setup"

  before { FactoryBot.create(:pricings_rate_basis) }

  describe ".state" do
    described_class::GRDB_RATE_BASIS_DATA.each do |grdb_rate_basis_datum|
      context "when GRDB rate basis is #{grdb_rate_basis_datum['grdb_rate_basis']}" do
        let(:row) do
          {
            "rate_basis" => grdb_rate_basis_datum["grdb_rate_basis"],
            "row" => 2,
            "organization_id" => organization.id
          }
        end
        let(:extracted_table) { described_class.state(state: state_arguments).frame }

        it "returns the frame with the rate_basis #{grdb_rate_basis_datum['grdb_rate_basis']}", :aggregate_failures do
          expect(extracted_table["rate_basis"].to_a).to eq([grdb_rate_basis_datum["rate_basis"]])
          expect(extracted_table["cbm_ratio"].to_a).to eq([grdb_rate_basis_datum["cbm_ratio"]])
          expect(extracted_table["vm_ratio"].to_a).to eq([grdb_rate_basis_datum["vm_ratio"]])
        end
      end
    end

    context "when not found" do
      let(:row) do
        {
          "rate_basis" => "AAA",
          "row" => 2,
          "organization_id" => organization.id
        }
      end

      it "does not affect the row without a grdb rate basis" do
        expect(described_class.state(state: state_arguments).frame["rate_basis"].to_a).to eq([row["rate_basis"]])
      end
    end
  end
end
