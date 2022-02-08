# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Overlaps
      class ExtendsPastExisting < ExcelDataServices::V3::Overlaps::Base
        # When the new validity starts during the existing one, but extends past its end. We update the existing validity to end before the new validity starts

        def updates
          [
            update_query(set_clause: set_clause, overlap_clause: overlap_clause)
          ]
        end

        def overlap_clause
          <<~SQL
            (validity @> :start_date::date AND upper(validity) < :end_date::date)
          SQL
        end

        def set_clause
          <<~SQL
            validity = daterange(lower(validity), :start_date)#{legacy_keys? ? ', effective_date = lower(validity), expiration_date = :start_date' : ''}
          SQL
        end
      end
    end
  end
end
