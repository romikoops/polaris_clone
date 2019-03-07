# frozen_string_literal: true

module Experiments
  module Trucking
    class Inserter
      include Scientist::Experiment

      attr_accessor :name, :percent_enabled

      def initialize(name:)
        @name = name
        @percent_enabled = 100
      end

      def enabled?
        percent_enabled.positive? && rand(100) < percent_enabled
      end

      def publish(result)
        bool = result.control.value[:stats][:trucking_pricings][:number_created] == result.candidates.first.value[:stats][:trucking_pricings][:number_created]
        Rails.logger.info "SCIENTIST: Results are equal: #{bool}"
      end
    end
  end
end
