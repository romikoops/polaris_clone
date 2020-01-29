# frozen_string_literal: true

module RmsData
  class Sheet < ApplicationRecord
    belongs_to :book, class_name: 'RmsData::Book'
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    has_many :cells, class_name: 'RmsData::Cell', dependent: :destroy

    def rows
      cells.order(:row).group_by(&:row).values.map { |v| v.sort_by!(&:column) }
    end

    def rows_values
      cells.order(:row).group_by(&:row).values.map { |v| v.sort_by!(&:column).map(&:value) }
    end

    def columns
      cells.order(:column).group_by(&:column).values.map { |v| v.sort_by!(&:row) }
    end

    def columns_values
      cells.order(:column).group_by(&:column).values.map { |v| v.sort_by!(&:row).map(&:value) }
    end

    def headers
      cells
        .where(row: 0)
        .order(:column)
    end

    def header_values
      cells
        .where(row: 0)
        .order(:column)
        .pluck(:value)
    end

    def row(index)
      cells.where(row: index).order(:column)
    end

    def column(index)
      cells.where(column: index).order(:row)
    end

    def row_values(index)
      row(index).pluck(:value)
    end

    def column_values(index)
      column(index).pluck(:value)
    end

    def cell(row:, column:)
      column_id = if column.is_a?(String)
                    header_values.index(column)
                  else
                    column
                  end
      cells.find_by(row: row, column: column_id)&.value
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
