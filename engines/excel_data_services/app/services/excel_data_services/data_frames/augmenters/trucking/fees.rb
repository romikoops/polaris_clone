# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Augmenters
      module Trucking
        class Fees < ExcelDataServices::DataFrames::Augmenters::Base
          def perform
            super
            remove_sheet_name
            return state if frame.empty?

            Legacy::ChargeCategory.import(charge_data, validate_uniqueness: true)
            state.frame = frame.inner_join(carriage_frame, on: { "direction" => "direction" })
            state
          end

          def charge_data
            new_fee_codes.map do |fee_code|
              charge_definition = frame[frame["fee_code"] == fee_code].to_a.first
              {
                "code" => fee_code.downcase,
                "organization_id" => state.organization_id,
                "name" => charge_definition["fee"]
              }
            end
          end

          def new_fee_codes
            fee_codes = frame["fee_code"].to_a.uniq.compact
            lowercase_with_original = fee_codes.map(&:downcase).zip(fee_codes).to_h
            existing_codes = Legacy::ChargeCategory.where(organization_id: state.organization_id, code: lowercase_with_original.keys).pluck(:code)
            lowercase_with_original.except(*existing_codes).values
          end
        end
      end
    end
  end
end
