# frozen_string_literal: true

module ExcelDataServices
  module Overlaps
    class ExtendsPastExisting < ExcelDataServices::Overlaps::Base
      def updates
        [
          update_query(set_clause: set_clause, overlap_clause: overlap_clause)
        ]
      end

      def overlap_clause
        <<~SQL
          (lower(validity) < :start_date::date AND upper(validity) < :end_date::date)
        SQL
      end

      def set_clause
        <<~SQL
          validity = daterange(lower(validity), :start_date)
        SQL
      end
    end
  end
end
