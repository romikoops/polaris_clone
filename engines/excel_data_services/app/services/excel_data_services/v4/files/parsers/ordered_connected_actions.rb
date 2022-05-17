# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class OrderedConnectedActions < ExcelDataServices::V4::Files::Parsers::Base
          KEYS = %i[pipelines].freeze
          attr_reader :section, :state

          def connected_actions
            @connected_actions ||= schema_data[:pipelines].map do |dependency_section|
              ExcelDataServices::V4::Files::Parsers::ConnectedActions.new(state: state, schema_data: dependency_section)
            end
          end
        end
      end
    end
  end
end
