# frozen_string_literal: true

require 'rails_helper'

module RmsData
  RSpec.describe Sheet, type: :model do
    context 'instance methods' do
      let!(:tenant) { FactoryBot.create(:legacy_tenant) }
      let!(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
      let!(:sheet) { FactoryBot.create(:rms_data_sheet, tenant: tenants_tenant) }
      let!(:headers) do
        %w(STATUS
           TYPE
           NAME
           CODE
           LATITUDE
           LONGITUDE
           COUNTRY
           FULL_ADDRESS
           PHOTO
           IMPORT_CHARGES
           EXPORT_CHARGES
           PRE_CARRIAGE
           ON_CARRIAGE
           ALTERNATIVE_NAMES)
      end

      describe 'rows' do
        it 'returns the values of the rows in order' do
          results = []
          [0, 1, 2, 3].each do |no|
            results << headers.map.with_index do |header, i|
              FactoryBot.create(:rms_data_cell,
                                tenant_id: tenants_tenant.id,
                                value: no.zero? ? header : "#{header} - value - ##{no}",
                                row: no,
                                column: i,
                                sheet: sheet)
            end
          end
          expect(sheet.rows).to eq(results)
        end
      end

      describe 'rows_values' do
        it 'returns the values of the rows in order' do
          results = []
          [0, 1, 2, 3].each do |no|
            sub_result = []
            headers.each_with_index do |header, i|
              sub_result << (no.zero? ? header : "#{header} - value - ##{no}")
              FactoryBot.create(:rms_data_cell,
                                tenant_id: tenants_tenant.id,
                                value: no.zero? ? header : "#{header} - value - ##{no}",
                                row: no,
                                column: i,
                                sheet: sheet)
            end
            results << sub_result
          end
          expect(sheet.rows_values).to eq(results)
        end
      end

      describe 'columns' do
        it 'returns the values of the columns in order' do
          results = Hash.new { |h,k| h[k] = [] }
          [0, 1, 2, 3].each do |no|
            headers.map.with_index do |header, i|
              results[header] << FactoryBot.create(:rms_data_cell,
                                tenant_id: tenants_tenant.id,
                                value: no.zero? ? header : "#{header} - value - ##{no}",
                                row: no,
                                column: i,
                                sheet: sheet)
            end
          end
          expect(sheet.columns).to eq(results.values)
        end
      end

      describe 'columns_values' do
        it 'returns the values of the columns in order' do
          results = Hash.new { |h,k| h[k] = [] }
          [0, 1, 2, 3].each do |no|
            headers.each_with_index do |header, i|
              results[header] << (no.zero? ? header : "#{header} - value - ##{no}")
              FactoryBot.create(:rms_data_cell,
                                tenant_id: tenants_tenant.id,
                                value: no.zero? ? header : "#{header} - value - ##{no}",
                                row: no,
                                column: i,
                                sheet: sheet)
            end
          end
          expect(sheet.columns_values).to eq(results.values)
        end
      end

      describe 'row(index)' do
        it 'returns the values of the desired row' do
          results = []
          [0, 1, 2, 3].each do |no|
            results << headers.map.with_index do |header, i|
              FactoryBot.create(:rms_data_cell,
                                tenant_id: tenants_tenant.id,
                                value: no.zero? ? header : "#{header} - value - ##{no}",
                                row: no,
                                column: i,
                                sheet: sheet)
            end
          end
          expect(sheet.row(1)).to eq(results[1])
        end
      end

      describe 'row_values(index)' do
        it 'returns the values of the desired row' do
          [0, 1, 2, 3].each do |no|
            headers.map.with_index do |header, i|
              FactoryBot.create(:rms_data_cell,
                                tenant_id: tenants_tenant.id,
                                value: no.zero? ? header : "#{header} - value - ##{no}",
                                row: no,
                                column: i,
                                sheet: sheet)
            end
          end
          expect(sheet.row_values(1)).to eq(headers.map{|h| "#{h} - value - ##{1}"})
        end
      end

      describe 'column(index)' do
        it 'returns the values of the desired column' do
          results = Hash.new { |h,k| h[k] = [] }
          [0, 1, 2, 3].each do |no|
            headers.map.with_index do |header, i|
              results[header] << FactoryBot.create(:rms_data_cell,
                                tenant_id: tenants_tenant.id,
                                value: no.zero? ? header : "#{header} - value - ##{no}",
                                row: no,
                                column: i,
                                sheet: sheet)
            end
          end
          expect(sheet.column(1)).to eq(results['TYPE'])
        end
      end

      describe 'column_values(index)' do
        it 'returns the values of the desired column' do
          results = Hash.new { |h,k| h[k] = [] }
          [0, 1, 2, 3].each do |no|
            headers.map.with_index do |header, i|
              results[header] << (no.zero? ? header : "#{header} - value - ##{no}")
              FactoryBot.create(:rms_data_cell,
                                tenant_id: tenants_tenant.id,
                                value: no.zero? ? header : "#{header} - value - ##{no}",
                                row: no,
                                column: i,
                                sheet: sheet)
            end
          end
          expect(sheet.column_values(1)).to eq(results['TYPE'])
        end
      end

      describe 'headers' do
        it 'returns the values of the header row' do
          results = []
          [0, 1, 2, 3].each do |no|
            results << headers.map.with_index do |header, i|
              FactoryBot.create(:rms_data_cell,
                                tenant_id: tenants_tenant.id,
                                value: no.zero? ? header : "#{header} - value - ##{no}",
                                row: no,
                                column: i,
                                sheet: sheet)
            end
          end
          expect(sheet.headers).to eq(results[0])
        end
      end

      describe 'headers_values' do
        it 'returns the values of the header row' do
          [0, 1, 2, 3].each do |no|
            headers.map.with_index do |header, i|
              FactoryBot.create(:rms_data_cell,
                                tenant_id: tenants_tenant.id,
                                value: no.zero? ? header : "#{header} - value - ##{no}",
                                row: no,
                                column: i,
                                sheet: sheet)
            end
          end
          expect(sheet.header_values).to eq(headers)
        end
      end

      describe 'cell' do
        it 'returns the value from row and column' do
          [0, 1, 2, 3].each do |no|
            headers.map.with_index do |header, i|
              FactoryBot.create(:rms_data_cell,
                                tenant_id: tenants_tenant.id,
                                value: no.zero? ? header : "#{header} - value - ##{no}",
                                row: no,
                                column: i,
                                sheet: sheet)
            end
          end
          expect(sheet.cell(row: 1, column: 0)).to eq('STATUS - value - #1')
        end

        it 'returns the value from row and header value' do
          [0, 1, 2, 3].each do |no|
            headers.map.with_index do |header, i|
              FactoryBot.create(:rms_data_cell,
                                tenant_id: tenants_tenant.id,
                                value: no.zero? ? header : "#{header} - value - ##{no}",
                                row: no,
                                column: i,
                                sheet: sheet)
            end
          end
          expect(sheet.cell(row: 1, column: 'NAME')).to eq('NAME - value - #1')
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: rms_data_sheets
#
#  id          :uuid             not null, primary key
#  metadata    :jsonb
#  name        :string
#  sheet_index :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  book_id     :uuid
#  tenant_id   :uuid
#
# Indexes
#
#  index_rms_data_sheets_on_book_id      (book_id)
#  index_rms_data_sheets_on_sheet_index  (sheet_index)
#  index_rms_data_sheets_on_tenant_id    (tenant_id)
#
