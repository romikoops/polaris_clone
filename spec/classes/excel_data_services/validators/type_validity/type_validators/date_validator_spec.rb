# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::TypeValidators::DateValidator do
  describe '.valid?' do
    it 'returns true if date is valid' do
      expect(described_class.new(Date.new)).to be_valid
    end

    it 'returns false if date is invalid' do
      expect(described_class.new(nil)).not_to be_valid
    end
  end
end
