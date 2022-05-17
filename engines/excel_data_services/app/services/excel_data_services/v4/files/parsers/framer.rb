# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class Framer < ExcelDataServices::V4::Files::Parsers::Base
          KEYS = %i[framer].freeze

          def framer
            @framer ||= if schema_data[:framer].present?
              "ExcelDataServices::V4::Framers::#{schema_data[:framer]}".constantize
            else
              ExcelDataServices::V4::Framers::Table
            end
          end

          def add_framer(klass)
            @framer = "ExcelDataServices::V4::Framers::#{klass}".constantize
          end
        end
      end
    end
  end
end
