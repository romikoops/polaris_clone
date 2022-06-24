# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Operations
      class CountryCodeFromLocode < ExcelDataServices::V4::Operations::Base
        def operation_result
          @operation_result ||= frame
            .left_join(origin_country_codes, on: { "origin_locode" => "origin_locode" })
            .left_join(destination_country_codes, on: { "destination_locode" => "destination_locode" })
        end

        def origin_country_codes
          @origin_country_codes ||= Rover::DataFrame.new({
            "origin_locode" => origin_locodes,
            "origin_country_code" => origin_locodes.map { |locode| locode[0..1] }
          })
        end

        def destination_country_codes
          @destination_country_codes ||= Rover::DataFrame.new({
            "destination_locode" => destination_locodes,
            "destination_country_code" => destination_locodes.map { |locode| locode[0..1] }
          })
        end

        def origin_locodes
          @origin_locodes ||= frame["origin_locode"].to_a.uniq
        end

        def destination_locodes
          @destination_locodes ||= frame["destination_locode"].to_a.uniq
        end
      end
    end
  end
end
