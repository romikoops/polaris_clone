# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::FileSerializer do
    let(:file) { FactoryBot.create(:legacy_file, :with_file) }
    let(:serialized_file) { described_class.new(file).serializable_hash }

    it "returns the correct url for the object passed" do
      expect(serialized_file.dig(:data, :attributes)).to have_key(:url)
    end

    it "returns the correct id for the object passed" do
      expect(serialized_file.dig(:data, :id)).to eq(file.id)
    end
  end
end
