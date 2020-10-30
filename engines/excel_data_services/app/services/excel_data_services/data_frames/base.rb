# frozen_string_literal: true

# Extraction classes dictate for each subsection of the sheet which pieces of data are pulled from the database

module ExcelDataServices
  module DataFrames
    class Base
      attr_reader :state

      delegate :frame, to: :state

      def self.state(state:)
        new(state: state).perform
      end

      def initialize(state:)
        @state = state
      end

      def perform
        performing_modules.inject(state) do |memo_state, performing_class|
          performing_class.state(state: memo_state)
        end
      end

      def performing_modules
        raise NotImplementedError, "This method must be implemented in #{self.class.name} "
      end
    end
  end
end
