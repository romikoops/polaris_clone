# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe MaxDimensionsBundle, type: :model do
    let!(:max_dimensions_bundle) { FactoryBot.build(:legacy_max_dimensions_bundle) }

    describe '.creates a valid object' do
      it 'builds a valid max dimensions bundle' do
        expect(max_dimensions_bundle).to be_valid
      end
    end
  end
end
