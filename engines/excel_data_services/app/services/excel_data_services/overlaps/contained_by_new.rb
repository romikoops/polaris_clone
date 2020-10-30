# frozen_string_literal: true

module ExcelDataServices
  module Overlaps
    class ContainedByNew < ExcelDataServices::Overlaps::Base
      def updates
        [
          update_query(set_clause: set_clause, overlap_clause: overlap_clause)
        ]
      end

      def overlap_clause
        <<~SQL
          (lower(validity) >= :start_date AND upper(validity) <= :end_date)
        SQL
      end

      def set_clause
        <<~SQL
          deleted_at = now()
        SQL
      end
    end
  end
end
