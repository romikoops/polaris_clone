# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      module Support
        class DateLimiter
          attr_reader :frame, :start_date, :end_date

          def initialize(frame:, start_date:, end_date:)
            @frame = frame
            @start_date = start_date
            @end_date = end_date
          end

          def perform
            frame["effective_date"][frame["effective_date"] < start_date] = start_date.to_date
            frame["expiration_date"][frame["expiration_date"] > end_date] = end_date.to_date
            frame
          end
        end
      end
    end
  end
end
