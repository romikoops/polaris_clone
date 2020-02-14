# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::TypeValidators::FeeValidator do
  describe '.valid?' do
    it 'returns true if fee is valid' do
      expect(described_class.new('n/a')).to be_valid
    end

    it 'returns false if fee is invalid' do
      expect(described_class.new(nil)).not_to be_valid
    end
  end
end
