# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Files
      module Parsers
        class OrderedConnectedActions < ExcelDataServices::V4::Files::Parsers::Base
          SPLIT_PATTERN = /^(NULLPATTERN)/.freeze
          attr_reader :section, :state

          def connected_actions
            @connected_actions ||= sorted_dependencies.map do |dependency_section|
              ExcelDataServices::V4::Files::Parsers::ConnectedActions.new(state: state, section: dependency_section)
            end
          end
        end
      end
    end
  end
end
