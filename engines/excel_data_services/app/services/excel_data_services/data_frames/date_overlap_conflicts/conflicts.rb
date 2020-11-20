# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DateOverlapConflicts
      class Conflicts
        attr_reader :table, :arguments, :date_range

        def self.conflicts(table:, arguments:)
          new(table: table, arguments: arguments).perform
        end

        def initialize(table:, arguments:)
          @table = table
          @arguments = arguments.symbolize_keys
        end

        def perform
          query_results.each_with_object({}) do |result, memo|
            result.each_key do |conflict_key|
              memo[conflict_key] = result[conflict_key] if memo[conflict_key].blank?
            end
            memo
          end
        end

        def query_results
          sanitized_query = ActiveRecord::Base.sanitize_sql_array([raw_query, binds])
          ActiveRecord::Base.connection.exec_query(sanitized_query).to_a
        end

        def raw_query
          <<~SQL
            SELECT
              (
                validity @> daterange(:start_date, :end_date)
                AND lower(validity) != :start_date
                AND upper(validity) != :end_date
              ) as contained_by_existing,
              (lower(validity) <= :start_date::date AND upper(validity) < :end_date::date) as extends_past_existing,
              (lower(validity) > :start_date::date AND upper(validity) >= :end_date::date) as extends_before_existing,
              (lower(validity) >= :start_date::date AND upper(validity) <= :end_date::date) as contained_by_new
            FROM #{table}
            WHERE #{attribute_query}
            AND validity && daterange(:start_date, :end_date)
            AND deleted_at IS NULL
          SQL
        end

        def binds
          arguments.merge(sql_dates)
        end

        def sql_dates
          {start_date: start_date, end_date: end_date}
        end

        def start_date
          arguments[:effective_date]
        end

        def end_date
          arguments[:expiration_date]
        end

        def attribute_query
          attributes.keys.map { |key| "#{key} = :#{key}" }.join(" AND ")
        end

        def attributes
          arguments.except(:effective_date, :expiration_date)
        end
      end
    end
  end
end
