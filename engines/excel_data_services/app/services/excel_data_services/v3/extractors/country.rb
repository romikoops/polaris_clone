# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Extractors
      class Country < ExcelDataServices::V3::Extractors::Base
        def frame_data
          Legacy::Country
            .select("id as country_id, code, name as country_name")
        end

        def join_arguments
          frame.include?("country") ? { "country" => "country_name" } : { "country_code" => "code" }
        end

        def frame_types
          { "country_id" => :object, "code" => :object, "country_name" => :object }
        end
      end
    end
  end
end
