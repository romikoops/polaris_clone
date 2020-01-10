# frozen_string_literal: true

require 'rails_helper'

module Pricings
  RSpec.describe Metadatum, type: :model do
    let(:metadatum) { FactoryBot.build(:pricings_metadatum) }

    describe '#valid?' do
      it 'build valid object' do
        expect(metadatum).to be_valid
      end
    end
  end
end
