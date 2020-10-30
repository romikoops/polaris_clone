# frozen_string_literal: true

module ExcelDataServices
  module Overlaps
    class ExtendsBeforeExisting < ExcelDataServices::Overlaps::Base
      def updates
        [
          update_query(set_clause: set_clause, overlap_clause: overlap_clause)
        ]
      end

      def overlap_clause
        <<~SQL
          (lower(validity) > :start_date::date AND upper(validity) > :end_date::date)
        SQL
      end

      def set_clause
        <<~SQL
          validity = daterange(:end_date, upper(validity))
        SQL
      end
    end
  end
end
