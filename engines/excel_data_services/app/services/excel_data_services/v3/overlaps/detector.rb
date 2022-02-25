# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Overlaps
      class Detector
        # The Overlaps::Detector class will determine whether there are any conflicts for the given keys and table in the database

        attr_reader :table, :arguments, :date_range

        def self.overlaps(table:, arguments:)
          new(table: table, arguments: arguments).perform
        end

        def initialize(table:, arguments:)
          @table = table
          @arguments = arguments.symbolize_keys
        end

        def perform
          query_results.uniq.inject([]) do |memo, result|
            memo | result.delete_if { |_key, value| value.blank? }.keys
          end
        end

        def query_results
          @query_results ||= begin
            sanitized_query = ActiveRecord::Base.sanitize_sql_array([raw_query, arguments])
            ActiveRecord::Base.connection.exec_query(sanitized_query).to_a
          end
        end

        def raw_query
          <<~SQL
            SELECT
            (validity @> daterange(:effective_date, :expiration_date, '[]') AND daterange(:effective_date, :expiration_date, '[]') != validity) as contained_by_existing,
              (lower(validity) <= :effective_date::date AND upper(validity) < :expiration_date::date) as extends_past_existing,
              (lower(validity) > :effective_date::date AND upper(validity) >= :expiration_date::date) as extends_before_existing,
              (daterange(:effective_date, :expiration_date, '[]') @> validity  OR daterange(:effective_date, :expiration_date, '[]') = validity) as contained_by_new
            FROM #{table}
            WHERE #{attributes_as_sql_where_clause}
            AND validity && daterange(:effective_date, :expiration_date)
            AND deleted_at IS NULL
          SQL
        end

        def attributes_as_sql_where_clause
          attributes.keys.map { |key| "#{key} = :#{key}" }.join(" AND ")
        end

        def attributes
          arguments.except(:effective_date, :expiration_date)
        end
      end
    end
  end
end
