# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Overlaps
      class ExtendsBeforeExisting < ExcelDataServices::V2::Overlaps::Base
        # This class handles when the new pricing predates the existing, but not past the existing expiration date.

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
            validity = daterange(:end_date, upper(validity))#{legacy_keys? ? ', effective_date = :end_date, expiration_date = upper(validity)' : ''}
          SQL
        end
      end
    end
  end
end
