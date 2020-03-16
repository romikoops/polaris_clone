# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::PdfSerializer do
    let(:file) { FactoryBot.create(:legacy_file, :with_file) }
    let(:serialized_file) { described_class.new(file).serializable_hash }

    it 'returns the correct name for the object passed' do
      expect(serialized_file.dig(:data, :attributes, :url)).to include('test.host')
    end
  end
end
