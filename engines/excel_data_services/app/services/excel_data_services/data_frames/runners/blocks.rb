# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Runners
      class Blocks
        attr_reader :file, :arguments

        def self.run(file:, arguments:)
          new(file: file, arguments: arguments).perform
        end

        def initialize(file:, arguments:)
          @file = file
          @arguments = arguments
        end

        def perform
          klass_name = file.class.to_s.demodulize
          "ExcelDataServices::DataFrames::Runners::#{klass_name}"
            .constantize
            .new(file: file, arguments: arguments)
            .perform
        end
      end
    end
  end
end
