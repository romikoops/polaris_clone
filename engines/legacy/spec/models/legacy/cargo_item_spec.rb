# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe CargoItem, type: :model do
    describe '.volume' do
      it 'calcs the volume' do
        cargo = FactoryBot.create(:legacy_cargo_item)
        expect(cargo.volume).to eq(0.008)
      end
    end
  end
end
