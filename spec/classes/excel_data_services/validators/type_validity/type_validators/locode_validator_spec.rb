# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::TypeValidators::LocodeValidator do
  describe '.valid?' do
    it 'returns true if locode is valid' do
      expect(described_class.new('abc de')).to be_valid
    end

    it 'returns false if locode is invalid' do
      expect(described_class.new(123)).not_to be_valid
    end
  end
end
