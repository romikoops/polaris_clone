# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Coordinators
      class Base < ExcelDataServices::DataFrames::Base
        def perform
          @state.frame = restructured_data
          @state.errors += combinator_errors
          @state
        end

        def combinator_errors
          @combinator_errors ||= combinator_state.errors
        end

        def combinator_frame
          @combinator_frame ||= combinator_state.frame
        end

        def combinator_state
          raise NotImplementedError, "This method must be implemented in #{self.class.name}"
        end

        def restructured_data
          raise NotImplementedError, "This method must be implemented in #{self.class.name}"
        end

        def coordinator_state
          ExcelDataServices::DataFrames::Coordinators::State.new(
            file: state.file,
            errors: [],
            frame: nil,
            hub_id: state.hub_id,
            group_id: state.group_id,
            organization_id: state.organization_id
          )
        end
      end
    end
  end
end
