# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Note, type: :model do
    let(:note) { FactoryBot.build(:legacy_note) }

    it 'must be valid' do
      expect(note.valid?).to be(true)
    end
  end
end
