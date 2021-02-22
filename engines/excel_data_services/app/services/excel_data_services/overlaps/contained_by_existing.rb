# frozen_string_literal: true

module ExcelDataServices
  module Overlaps
    class ContainedByExisting < ExcelDataServices::Overlaps::Base
      def updates
        [
          update_past,
          update_future
        ].compact
      end

      def overlap_clause
        <<~SQL
          (validity @> daterange(:start_date, :end_date))
        SQL
      end

      def past_set_clause
        <<~SQL
          validity = daterange(lower(validity), :start_date)
        SQL
      end

      def update_past
        conflicting_validity
        update_query(set_clause: past_set_clause, overlap_clause: overlap_clause)
      end

      def update_future
        return nil if end_date == new_end_date

        <<~SQL
          WITH targets AS (
            SELECT * FROM
              #{table}
            WHERE
              #{attribute_query}
            AND
              validity @> :adjusted_date::date
          )
          INSERT INTO #{table} (#{model_attributes.join(", ")}, created_at, updated_at)
          SELECT #{(model_attributes - ["validity"]).join(", ")},  daterange(:end_date, :new_end_date), now(), now()
          FROM targets
        SQL
      end

      def model_attributes
        @model_attributes ||= model.given_attribute_names
      end

      def binds
        super.merge(
          adjusted_date: adjusted_date,
          new_end_date: new_end_date
        )
      end

      def adjusted_date
        start_date - 1.day
      end

      def new_end_date
        @new_end_date ||= conflicting_validity.last
      end

      def conflicting_validity
        @conflicting_validity ||= model.find_by(attributes).validity
      end
    end
  end
end
