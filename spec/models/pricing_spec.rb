# frozen_string_literal: true

require 'rails_helper'

describe Pricing, type: :model do
  subject { create(:pricing) }

  context 'validations' do
    let(:duplicate_pricing) { subject.dup }

    it 'validates uniqueness' do
      expect(duplicate_pricing).not_to be_valid
    end
  end
end
