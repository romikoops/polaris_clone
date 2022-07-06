# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class StringValidity < ExcelDataServices::V4::Extractors::Base
        def frame_data
          periods.map do |period|
            period.merge("validity" => "[#{period['effective_date'].to_date}, #{period['expiration_date'].to_date})")
          end
        end

        def join_arguments
          { "effective_date" => "effective_date", "expiration_date" => "expiration_date" }
        end

        def frame_types
          { "effective_date" => :object, "expiration_date" => :object, "validity" => :object }
        end

        def periods
          @periods ||= frame[%w[effective_date expiration_date]].to_a.uniq
        end
      end
    end
  end
end
