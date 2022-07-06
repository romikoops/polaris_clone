# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class DistributionHub < ExcelDataServices::V4::Extractors::Base
        private

        def extracted
          rows_to_ignore.concat(updated_rows)
        end

        def updated_rows
          @updated_rows ||= rows_to_update.left_join(hub_frame, on: { "organization_id" => "organization_id" })
        end

        def hub_frame
          @hub_frame ||= Rover::DataFrame.new(
            Legacy::Hub.where(organization_id: organization_ids).select("hubs.id as hub_id, hubs.organization_id")
          )
        end

        def original_hub
          @original_hub ||= Legacy::Hub.find(frame.first_row["hub_id"])
        end

        def rows_to_ignore
          @rows_to_ignore ||= frame.filter("hub_id" => original_hub.id, "organization_id" => original_hub.organization_id)
        end

        def rows_to_update
          @rows_to_update ||= frame.filter("hub_id" => original_hub.id).reject("organization_id" => original_hub.organization_id)
        end
      end
    end
  end
end
