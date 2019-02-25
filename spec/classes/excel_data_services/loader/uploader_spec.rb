# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Loader::Uploader do
  let(:tenant) { create(:tenant) }
  let(:specific_identifier) {}
  let(:file_or_path) {}
  let(:uploader) do
    described_class.new(
      tenant: tenant,
      specific_identifier: specific_identifier,
      file_or_path: file_or_path
    )
  end

  describe '#perform' do
    let(:generic_parser) { double('GenericParser') }
    let(:generic_validator) { double('GenericValidator') }

    it 'returns an error log when errors were put into the errors array' do
      expect(ExcelDataServices::FileParser).to receive(:get).and_return(generic_parser)
      expect(generic_parser).to receive(:parse).and_return({})
      expect(ExcelDataServices::DataValidator::Base).to receive(:get).and_return(generic_validator)
      expect(generic_validator).to receive(:validate).and_return([{ row_nr: 1, reason: 'mock error message' }])
      expect(uploader.perform).to eq(has_errors: true, errors: [{ row_nr: 1, reason: 'mock error message' }])
    end

    context 'with Pricings' do
      let(:specific_identifier) { 'OceanLcl' }
      let(:pricings_parser) { double('Pricings') }
      let(:raw_data) { build(:excel_data_parsed_correct_pricings) }
      let!(:hubs) do
        [create(:hub, name: 'Gothenburg Port', tenant: tenant),
         create(:hub, name: 'Shanghai Port', tenant: tenant)]
      end

      it 'returns successfully' do
        expect(ExcelDataServices::FileParser).to receive(:get).and_return(pricings_parser)
        expect(pricings_parser).to receive(:parse).and_return(raw_data)
        expect(uploader.perform).to eq(itineraries: { number_created: 1, number_updated: 0 },
                                       pricing_details: { number_created: 1, number_updated: 0 },
                                       pricings: { number_created: 1, number_updated: 0 },
                                       stops: { number_created: 2, number_updated: 0 })
      end
    end

    context 'with Local Charges' do
      let(:specific_identifier) { 'LocalCharges' }
      let(:local_charges_parser) { double('LocalCharges') }
      let(:raw_data) { build(:excel_data_parsed_correct_local_charges) }
      let!(:hubs) { [create(:hub, name: 'Bremerhaven Port', tenant: tenant)] }

      it 'returns successfully' do
        expect(ExcelDataServices::FileParser).to receive(:get).and_return(local_charges_parser)
        expect(local_charges_parser).to receive(:parse).and_return(raw_data)
        expect(uploader.perform).to eq(local_charges: { number_created: 1, number_updated: 0 })
      end
    end
  end
end
