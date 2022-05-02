# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Overlaps
      class ContainedByExisting < ExcelDataServices::V4::Overlaps::Base
        # When the new pricing exists entirely within the existing conflict, this class will split the conflicting record in two, leaving a gap in validity for the new record to be inserted

        def updates
          [
            update_past,
            update_future
          ].compact
        end

        def overlap_clause
          <<~SQL.squish
            (validity @> daterange(:start_date, :end_date, '[]') AND daterange(:start_date, :end_date, '[]') != validity)
          SQL
        end

        def past_set_clause
          <<~SQL.squish
            validity = daterange(lower(validity), :start_date, '[)') #{legacy_keys? ? ', effective_date = lower(validity), expiration_date = :start_date' : ''}
          SQL
        end

        def update_past
          conflicting_validity
          update_query(set_clause: past_set_clause, overlap_clause: overlap_clause)
        end

        def update_future
          return nil if end_date == new_end_date - 1.day

          <<~SQL.squish
            WITH targets AS (
              SELECT * FROM
                #{table_name}
              WHERE
                #{attribute_query}
              AND
                validity @> :adjusted_date::date
            )
            INSERT INTO #{table_name} (#{model_attributes_string}, validity#{legacy_keys? ? ', effective_date, expiration_date' : ''}, created_at, updated_at)
            SELECT #{model_attributes_string}, daterange(:new_validity_start, :new_validity_end)#{legacy_keys? ? ', :end_date, :new_end_date' : ''}, now(), now()
            FROM targets
          SQL
        end

        def model_attributes_string
          @model_attributes_string ||= (attribute_names - %w[id created_at updated_at validity effective_date expiration_date]).join(", ")
        end

        def binds
          super.merge(
            adjusted_date: adjusted_date,
            new_end_date: new_end_date,
            new_validity_end: new_validity_end,
            new_validity_start: new_validity_start
          )
        end

        def adjusted_date
          start_date - 1.day
        end

        def new_end_date
          @new_end_date ||= (new_validity_end - 1.day).end_of_day
        end

        def new_validity_end
          @new_validity_end ||= conflicting_validity.last
        end

        def new_validity_start
          @new_validity_start ||= end_date + 1.day
        end

        def conflicting_validity
          @conflicting_validity ||= model.where("validity && daterange(?::date, ?::date)", arguments[:effective_date], arguments[:expiration_date]).find_by(attributes_excluding_dates).validity
        end
      end
    end
  end
end
