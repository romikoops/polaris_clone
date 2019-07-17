# frozen_string_literal: true

module RmsData
  class Sheet < ApplicationRecord
    belongs_to :book, class_name: 'RmsData::Book'
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    has_many :cells, class_name: 'RmsData::Cell', dependent: :destroy

    def rows
      cells.order(:row).group_by(&:row).values.map { |v| v.sort_by!(&:column).map(&:value) }
    end

    def headers
      cells
        .where(row: 0)
        .order(:column)
        .pluck(:value)
    end

    def row(index)
      cells.where(row: index).order(:column).pluck(:value)
    end

    def cell(row:, column:)
      column_id = if column.is_a?(String)
         headers.index(column)
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
#  sheet_index :integer
#  tenant_id   :uuid
#  book_id     :uuid
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
