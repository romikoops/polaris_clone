# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Overlaps
      class Base
        # With validity periods come conflicts. These Overlap classes handle each type of overlap. Common code is housed here.

        delegate :attribute_names, :table_name, to: :model

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

        private

        attr_reader :model, :arguments

        def update_query(set_clause:, overlap_clause:)
          <<~SQL.squish
            UPDATE #{table_name}
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
          { start_date: start_date, end_date: end_date }
        end

        def start_date
          arguments[:effective_date]
        end

        def end_date
          arguments[:expiration_date]
        end

        def attribute_query
          arguments.except(:effective_date, :expiration_date).keys.map { |key| "#{key} = :#{key}" }.join(" AND ")
        end

        def attributes_excluding_dates
          arguments.except(:effective_date, :expiration_date)
        end

        def legacy_keys?
          attribute_names.include?("effective_date") && attribute_names.include?("expiration_date")
        end
      end
    end
  end
end
