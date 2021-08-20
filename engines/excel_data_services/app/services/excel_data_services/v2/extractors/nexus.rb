# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class Nexus < ExcelDataServices::V2::Extractors::Base
        def frame_data
          Legacy::Nexus
            .joins(:country)
            .where(organization_id: Organizations.current_id)
            .select("nexuses.id as nexus_id, locode, countries.name as country")
        end

        def join_arguments
          { "locode" => "locode", "country" => "country" }
        end

        def frame_types
          { "nexus_id" => :object, "locode" => :object }
        end

        def error_reason(row:)
          "The nexus '#{row['name']} (#{row['locode']})' cannot be found."
        end

        def required_key
          "nexus_id"
        end
      end
    end
  end
end
