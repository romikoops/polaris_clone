# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::CargoItemTypeSerializer do
    let(:cargo_item_type) { FactoryBot.create(:legacy_cargo_item_type) }
    let(:serialized_cargo_item) { described_class.new(cargo_item_type).serializable_hash }
    let(:target) { serialized_cargo_item.dig(:data, :attributes) }

    it 'returns the correct length for the object passed' do
      expect(target[:length]).to eq(121)
    end

    it 'returns the correct width for the object passed' do
      expect(target[:width]).to eq(101)
    end
  end
end
