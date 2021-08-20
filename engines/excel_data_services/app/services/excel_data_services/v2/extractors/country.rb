# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class Country < ExcelDataServices::V2::Extractors::Base
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

        def error_reason(row:)
          "The country '#{row.values_at('country', 'country_code').compact.join(' ')}' cannot be found."
        end

        def required_key
          "country_id"
        end
      end
    end
  end
end
