# frozen_string_literal: true

module ExcelDataServices
  module Extractors
    class Nexus < ExcelDataServices::Extractors::Base
      def frame_data
        Legacy::Nexus
          .where(organization_id: Organizations.current_id)
          .select("nexuses.id as nexus_id, locode")
      end

      def join_arguments
        { "locode" => "locode" }
      end

      def frame_types
        { "nexus_id" => :object, "locode" => :object }
      end
    end
  end
end
