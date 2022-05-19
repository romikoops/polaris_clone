# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class Nexus < ExcelDataServices::V4::Extractors::Base
        def frame_data
          Legacy::Nexus
            .joins(:country)
            .where(organization_id: organization_ids)
            .select("nexuses.id as nexus_id, locode, countries.name as country, organization_id")
        end

        def join_arguments
          { "locode" => "locode", "country" => "country", "organization_id" => "organization_id" }
        end

        def frame_types
          { "nexus_id" => :object, "locode" => :object }
        end
      end
    end
  end
end
