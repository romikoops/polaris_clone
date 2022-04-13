# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      module Support
        class ChargeCategoryData
          attr_reader :frame

          def initialize(frame:)
            @frame = frame
          end

          def perform
            frame.inner_join(charge_category_frame, on: { "code" => "code" })
          end

          def charge_category_frame
            @charge_category_frame ||= Rover::DataFrame.new(
              Legacy::ChargeCategory.where(organization_id: Organizations.current_id)
              .select("code, id as charge_category_id")
            )
          end
        end
      end
    end
  end
end
