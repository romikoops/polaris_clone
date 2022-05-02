# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class Framer < ExcelDataServices::V4::Files::Parsers::Base
          SPLIT_PATTERN = /^(add_framer)/.freeze

          def framer
            @framer ||= ExcelDataServices::V4::Framers::Table
          end

          def add_framer(klass)
            @framer = "ExcelDataServices::V4::Framers::#{klass}".constantize
          end
        end
      end
    end
  end
end
