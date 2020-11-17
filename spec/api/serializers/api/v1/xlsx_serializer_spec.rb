# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::XlsxSerializer do
    let(:file) { FactoryBot.create(:legacy_file, :with_file) }
    let(:serialized_sheet) { described_class.new(file).serializable_hash }

    it "returns the correct name for the sheet" do
      expect(serialized_sheet.dig(:data, :id)).to eq(file.id)
    end
  end
end
