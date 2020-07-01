# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Restructurers::LocalCharges do
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, data: input_data } }

  describe '.restructure' do
    context 'without expansion based on counterpart hubs' do
      let(:input_data) { build(:excel_data_parsed_correct_local_charges).first }
      let(:output_data) { { 'LocalCharges' => build(:excel_data_restructured_correct_local_charges) } }

      it 'restructures the data correctly' do
        expect(described_class.restructure(options)).to eq(output_data)
      end
    end

    context 'with expansion based on counterpart hubs' do
      let(:input_data) { build(:excel_data_parsed_correct_local_charges_with_counterpart_expansion).first }
      let(:output_data) do
        { 'LocalCharges' => build(:excel_data_restructured_correct_local_charges_with_counterpart_expansion) }
      end

      let(:scope_service) { instance_double(::Tenants::ScopeService) }

      before do
        expect(::Tenants::ScopeService).to receive(:new).and_return(scope_service)
        expect(scope_service).to receive(:fetch).and_return("expand_non_counterpart_local_charges" => true)
      end

      it 'restructures the data correctly' do
        expect(described_class.restructure(options)).to eq(output_data)
      end
    end
  end
end
