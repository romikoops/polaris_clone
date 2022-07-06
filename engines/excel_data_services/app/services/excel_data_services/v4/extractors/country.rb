# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class Country < ExcelDataServices::V4::Extractors::Base
        def frame_data
          Legacy::Country.select("id as country_id, code as country_code, name as country_name")
        end

        def join_arguments
          frame.include?("country") ? { "country" => "country_name" } : { "country_code" => "country_code" }
        end

        def frame_types
          { "country_id" => :object, "country_code" => :object, "country_name" => :object }
        end
      end
    end
  end
end
