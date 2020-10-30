# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Coordinators
      module Truckings
        class Base < ExcelDataServices::DataFrames::Coordinators::Base
          def combinator_state
            @combinator_state ||= combinator.state(coordinator_state: state)
          end

          def restructured_data
            @restructured_data ||= restructurer.data(frame: combinator_frame)
          end

          def combinator
            raise NotImplementedError, "This method must be implemented in #{self.class.name}"
          end

          def restructurer
            raise NotImplementedError, "This method must be implemented in #{self.class.name}"
          end
        end
      end
    end
  end
end
