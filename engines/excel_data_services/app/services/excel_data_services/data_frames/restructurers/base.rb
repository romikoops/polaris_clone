# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Restructurers
      class Base
        attr_reader :frame, :options

        def self.data(frame:, options: {})
          new(frame: frame, options: options).perform
        end

        def initialize(frame:, options: {})
          @frame = frame
          @options = options
        end

        def perform
          Rover::DataFrame.new(restructured_data)
        end

        def trimmed_row(row:)
          result = row.to_h.compact
          result.each_key do |key|
            result.delete(key) if result[key].to_s == "NaN"
          end
          result
        end
      end
    end
  end
end
