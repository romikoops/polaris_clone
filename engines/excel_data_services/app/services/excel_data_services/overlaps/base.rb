# frozen_string_literal: true

module ExcelDataServices
  module Overlaps
    class Base
      attr_reader :model, :arguments

      def initialize(model:, arguments:)
        @model = model
        @arguments = arguments.symbolize_keys
      end

      def perform
        updates.each do |update|
          sanitized_query = ActiveRecord::Base.sanitize_sql_array([update, binds])
          ActiveRecord::Base.connection.exec_query(sanitized_query)
        end
      end

      def update_query(set_clause:, overlap_clause:)
        <<~SQL
          UPDATE #{table}
          SET #{set_clause}
          WHERE #{attribute_query}
          AND #{overlap_clause}
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

      def table
        @table ||= model.table_name
      end
    end
  end
end
