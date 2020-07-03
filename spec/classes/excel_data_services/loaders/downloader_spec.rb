# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Loaders::Downloader do
  let(:organization) { create(:organizations_organization) }
  let(:downloader) { described_class.new(organization: organization, category_identifier: category_identifier, file_name: file_name, sandbox: nil) }
  let(:category_identifier) { 'LocalCharges' }
  let(:file_name) { 'xyz.xlsx' }

  describe '#perform' do
    it 'instantiates the correct file writer and calls the write_document method' do
      expect(ExcelDataServices::FileWriters::Base).to receive(:write_document)
      downloader.perform
    end
  end
end
