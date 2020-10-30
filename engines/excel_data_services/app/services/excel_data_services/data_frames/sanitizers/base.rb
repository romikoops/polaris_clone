# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      class Base < ExcelDataServices::DataFrames::Base
        def perform
          @state.frame = sanitized_with_defaults
          @state
        end

        private

        attr_reader :state

        def frame
          state.frame
        end

        def rows
          @rows ||= frame.to_a
        end

        def sanitized_frame
          @sanitized_frame ||= Rover::DataFrame.new(sanitized_data, types: filtered_column_types)
        end

        def sanitized_with_defaults
          return sanitized_frame if default_values.empty?

          sanitized_frame[:join_id] = join_id
          result = sanitized_frame.inner_join(default_values_frame, on: :join_id)
          result.delete(:join_id)
          result
        end

        def sanitized_data
          sanitizer_lookup.each do |attribute, type|
            next unless frame.include?(attribute)

            sanitize_attribute(attribute: attribute, type: type)
          end

          rows
        end

        def default_values_frame
          Rover::DataFrame.new([default_values_data], types: column_types)
        end

        def default_values_data
          default_values.each_with_object({join_id: join_id}) do |(key, value), result|
            next if frame.include?(key) && frame[key].any?(&:present?)

            result[key] = value
          end
        end

        def join_id
          @join_id ||= SecureRandom.uuid
        end

        def sanitize_attribute(attribute:, type:)
          sanitizer_klass = "ExcelDataServices::Sanitizers::#{type.camelize}Sanitizer".safe_constantize
          return rows if sanitizer_klass.blank?

          rows.each do |row|
            row[attribute] = sanitizer_klass.sanitize(value: row[attribute])
          end
        end

        def filtered_column_types
          column_types.slice(*frame.keys)
        end

        def column_types
          @column_types ||= begin
            provider_klass = self.class.to_s.gsub("Sanitizers", "DataProviders").safe_constantize
            provider_klass.column_types
          end
        end

        def default_values
          {}
        end
      end
    end
  end
end
