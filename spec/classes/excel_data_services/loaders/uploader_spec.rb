# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Loaders::Uploader do
  let(:tenant) { create(:tenant) }
  let(:category_identifier) {}
  let(:file_or_path) {}
  let(:uploader) do
    ExcelDataServices::Loaders::Uploader.new(
      tenant: tenant,
      file_or_path: file_fixture('excel').join('dummy.xlsx')
    )
  end

  describe '#perform' do
    let(:header_validator) { instance_double('HeaderChecker') }
    let(:flavor_based_validator_klass) { double('FlavorBasedValidator') }
    let(:flavor_based_validator) { instance_double('FlavorBasedValidator') }
    let(:inserter_klass) { double('Inserter') }

    it 'reads the excel file in and calls the correct methods.' do
      expect(ExcelDataServices::Validators::HeaderChecker).to receive(:new).exactly(2).times.and_return(header_validator)
      expect(header_validator).to receive(:perform).exactly(2).times
      expect(header_validator).to receive(:valid?).exactly(2).times.and_return(true)
      expect(header_validator).to receive(:restructurer_name).exactly(2).times.and_return('')
      expect(ExcelDataServices::FileParser).to receive(:parse).and_return([{sheet_name: 'DummySheet'}])
      expect(ExcelDataServices::Restructurers::Base).to receive(:restructure).and_return(DummyInsertionType: [])
      expect(ExcelDataServices::Validators::Base).to receive(:get).exactly(3).times.and_return(flavor_based_validator_klass)
      expect(flavor_based_validator_klass).to receive(:new).exactly(3).times.and_return(flavor_based_validator)
      expect(flavor_based_validator).to receive(:perform).exactly(3).times
      expect(flavor_based_validator).to receive(:valid?).exactly(3).times.and_return(true)
      expect(ExcelDataServices::Inserters::Base).to receive(:get).and_return(inserter_klass)
      expect(inserter_klass).to receive(:insert).and_return({})
      uploader.perform
    end
  end
end
