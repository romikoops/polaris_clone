# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Files
      module Parsers
        class Framer < ExcelDataServices::V3::Files::Parsers::Base
          SPLIT_PATTERN = /^(add_framer)/.freeze

          def framer
            @framer ||= ExcelDataServices::V3::Framers::Table
          end

          def add_framer(klass)
            @framer = "ExcelDataServices::V3::Framers::#{klass}".constantize
          end
        end
      end
    end
  end
end
