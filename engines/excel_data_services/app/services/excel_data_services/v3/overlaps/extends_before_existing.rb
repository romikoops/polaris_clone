# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Overlaps
      class ExtendsBeforeExisting < ExcelDataServices::V3::Overlaps::Base
        # This class handles when the new pricing predates the existing, but not past the existing expiration date.

        def updates
          [
            update_query(set_clause: set_clause, overlap_clause: overlap_clause)
          ]
        end

        def overlap_clause
          <<~SQL
            (lower(validity) > :start_date::date AND validity @> :end_date::date)
          SQL
        end

        def set_clause
          <<~SQL
            validity = daterange(:new_start_date, upper(validity))#{legacy_keys? ? ', effective_date = :end_date, expiration_date = upper(validity)' : ''}
          SQL
        end

        def binds
          super.merge(
            new_start_date: new_start_date
          )
        end

        def new_start_date
          end_date + 1.day
        end
      end
    end
  end
end
