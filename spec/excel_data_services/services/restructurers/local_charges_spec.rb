# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Restructurers::LocalCharges do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:options) { {organization: organization, data: input_data} }

  describe ".restructure" do
    context "without expansion based on counterpart hubs" do
      let(:input_data) { FactoryBot.build(:excel_data_parsed_correct_local_charges).first }
      let(:output_data) { {"LocalCharges" => FactoryBot.build(:excel_data_restructured_correct_local_charges)} }

      it "restructures the data correctly" do
        expect(described_class.restructure(options)).to eq(output_data)
      end
    end

    context "with expansion based on counterpart hubs" do
      let(:input_data) { FactoryBot.build(:excel_data_parsed_correct_local_charges_with_counterpart_expansion).first }
      let(:output_data) do
        {"LocalCharges" => FactoryBot.build(:excel_data_restructured_correct_local_charges_with_counterpart_expansion)}
      end

      let(:scope_service) { instance_double(::OrganizationManager::ScopeService) }

      before do
        expect(::OrganizationManager::ScopeService).to receive(:new).and_return(scope_service)
        expect(scope_service).to receive(:fetch).and_return("expand_non_counterpart_local_charges" => true)
      end

      it "restructures the data correctly" do
        expect(described_class.restructure(options)).to eq(output_data)
      end
    end
  end
end
