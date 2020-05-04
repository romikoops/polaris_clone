# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Validators::MissingValues::MaxDimensions do
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, sheet_name: 'Sheet1', data: input_data } }

  context 'with faulty data' do
    let(:input_data) do
      [
        {
          sheet_name: 'Sheet1',
          restructurer_name: 'max_dimensions',
          carrier: 'msc',
          service_level: 'standard',
          mode_of_transport: 'ocean',
          dimension_x: nil,
          dimension_y: nil,
          dimension_z: nil,
          payload_in_kg: 10_000,
          chargeable_weight: nil,
          cargo_class: 'fcl_20',
          aggregate: false,
          row_nr: 2
        },
        {
          sheet_name: 'Sheet1',
          restructurer_name: 'max_dimensions',
          carrier: 'msc',
          service_level: 'standard',
          mode_of_transport: 'ocean',
          dimension_x: nil,
          dimension_y: nil,
          dimension_z: nil,
          payload_in_kg: nil,
          chargeable_weight: nil,
          cargo_class: nil,
          aggregate: nil,
          row_nr: 3
        }
      ].map { |row| ExcelDataServices::Rows::MaxDimensions.new(tenant: tenant, row_data: row) }
    end
    let(:validator) { described_class.new(options) }

    describe '.validate' do
      before do
        validator.perform
      end

      let(:expected_errors) do
        [
          {  exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues,
             reason: 'Missing value for PAYLOAD_IN_KG.',
             row_nr: 3,
             sheet_name: 'Sheet1',
             type: :error },
          {  exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues,
             reason: 'Missing value for DIMENSION_Z.',
             row_nr: 3,
             sheet_name: 'Sheet1',
             type: :error },
          {  exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues,
             reason: 'Missing value for DIMENSION_Y.',
             row_nr: 3,
             sheet_name: 'Sheet1',
             type: :error },
          {  exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues,
             reason: 'Missing value for DIMENSION_X.',
             row_nr: 3,
             sheet_name: 'Sheet1',
             type: :error },
          {  exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues,
             reason: 'Missing value for CHARGEABLE_WEIGHT.',
             row_nr: 3,
             sheet_name: 'Sheet1',
             type: :error },
          {  exception_class: ExcelDataServices::Validators::ValidationErrors::MissingValues,
             reason: 'Missing value for LOAD_TYPE.',
             row_nr: 3,
             sheet_name: 'Sheet1',
             type: :error }
        ]
      end

      it 'logs the errors' do
        expect(validator.results).to match_array(expected_errors)
      end
    end
  end
end
