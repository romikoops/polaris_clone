# frozen_string_literal: true

RSpec.describe ExcelDataServices::Validators::TypeValidity::TypeValidators::DateValidator do
  describe '.valid?' do
    it 'returns true if date is valid' do
      expect(described_class.new(Date.new)).to be_valid
    end

    it 'returns true if date string is valid with yyyy/mm/dd' do
      expect(described_class.new('2020/01/19')).to be_valid
    end

    it 'returns false if date string is invalid due to invalid year format yy/mm/dd' do
      expect(described_class.new('01/01/19')).not_to be_valid
    end

    it 'returns false if date string is invalid due to switched day and month format yyyy/dd/mm' do
      expect(described_class.new('2020/24/08')).not_to be_valid
    end

    it 'returns false if date string is invalid because blank' do
      expect(described_class.new('')).not_to be_valid
    end

    it 'returns false if date is invalid because nil value' do
      expect(described_class.new(nil)).not_to be_valid
    end
  end
end
