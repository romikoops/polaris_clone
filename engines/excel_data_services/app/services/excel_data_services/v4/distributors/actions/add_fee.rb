# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Distributors
      module Actions
        class AddFee < ExcelDataServices::V4::Distributors::Actions::Base
          RATE_KEYS = %w[rate range_min range_max fee_code fee_name minimum maximum rate_basis wm_ratio vm_ratio notes].freeze

          def perform
            frame.concat(new_fees_frame)
          end

          private

          def unique_routes
            @unique_routes ||= affected_rows[identifying_keys].to_a.uniq
          end

          def new_fees_frame
            @new_fees_frame ||= Rover::DataFrame.new(
              unique_routes.map { |route| route.merge(new_fee) }
            )
          end

          def new_fee
            base_fee_arguments.merge(arguments)
          end

          def base_fee_arguments
            RATE_KEYS.each_with_object({}) { |key, res| res[key] = nil }
          end

          def identifying_keys
            @identifying_keys ||= frame.keys - RATE_KEYS
          end
        end
      end
    end
  end
end
