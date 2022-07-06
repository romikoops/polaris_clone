# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class OrganizationCarrier < ExcelDataServices::V4::Extractors::Base
        PLACEHOLDER = "ORGANIZATION_SLUG"

        def frame_data
          Organizations::Organization.where(id: organization_ids).map do |org|
            { "join_value" => PLACEHOLDER, "carrier_code" => org.slug, "carrier" => org.slug.humanize, "organization_id" => org.id }
          end
        end

        def join_arguments
          { "carrier_code" => "join_value", "organization_id" => "organization_id" }
        end

        def frame_types
          { "carrier_code" => :object, "join_value" => :object, "organization_id" => :object }
        end
      end
    end
  end
end
