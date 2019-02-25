module Experiments
  module Trucking
    class FindByFilter
      include Scientist::Experiment

      attr_accessor :name, :percent_enabled

      def initialize(name:)
        @name = name
        @percent_enabled = 100
      end

      def enabled?
        percent_enabled > 0 && rand(100) < percent_enabled
      end

      def publish(result)
        Rails.logger.info "SCIENTIST: Results are equal: #{result.control.value.first&.rates == result.candidates.first.value.first&.rates}"
      end
    end
  end
end