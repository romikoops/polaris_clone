# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Validators::TypeValidity::ScheduleGenerator do
  describe '.type_errors' do
    let(:valid_data_sheet) { FactoryBot.build(:schedule_generator_data).first }

    it 'returns no type errors with valid data the specified sheet validator' do
      type_validator_class = described_class.get(valid_data_sheet[:restructurer_name])
      type_validator = type_validator_class.new(sheet: valid_data_sheet)
      expect(type_validator.type_errors).to eq([])
    end
  end
end
