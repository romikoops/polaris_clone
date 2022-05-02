# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Overlaps
      class ContainedByNew < ExcelDataServices::V4::Overlaps::Base
        def updates
          [
            update_query(set_clause: set_clause, overlap_clause: overlap_clause)
          ]
        end

        def overlap_clause
          <<~SQL.squish
            (daterange(:start_date, :end_date, '[]') @> validity  OR daterange(:start_date, :end_date, '[]') = validity)
          SQL
        end

        def set_clause
          <<~SQL.squish
            deleted_at = now()
          SQL
        end
      end
    end
  end
end
