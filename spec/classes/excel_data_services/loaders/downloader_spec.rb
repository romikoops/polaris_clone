# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Loaders::Downloader do
  let(:tenant) { create(:tenant) }
  let(:downloader) { described_class.new(tenant: tenant, specific_identifier: specific_identifier, file_name: file_name) }
  let(:specific_identifier) { 'LocalCharges' }
  let(:file_name) { 'xyz.xlsx' }

  describe '#perform' do
    it 'instantiates the correct file writer and calls the write_document method' do
      expect(ExcelDataServices::FileWriters::Base).to receive(:write_document)
      downloader.perform
    end
  end
end
