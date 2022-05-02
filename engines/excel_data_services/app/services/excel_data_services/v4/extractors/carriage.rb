# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class Carriage < ExcelDataServices::V4::Extractors::Base
        def frame_data
          [{ "carriage" => "pre", "direction" => "export" }, { "carriage" => "on", "direction" => "import" }]
        end

        def join_arguments
          { "direction" => "direction" }
        end

        def frame_types
          { "direction" => :object, "carriage" => :object }
        end
      end
    end
  end
end
