# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      module Hubs
        class Hubs < ExcelDataServices::DataFrames::Sanitizers::Base
          def sanitizer_lookup
            {
              "status" => "string",
              "type" => "string",
              "name" => "string",
              "locode" => "string",
              "terminal" => "string",
              "terminal_code" => "string",
              "latitude" => "decimal",
              "longitude" => "decimal",
              "country" => "string",
              "full_address" => "string",
              "free_out" => "boolean",
              "import_charges" => "boolean",
              "export_charges" => "boolean",
              "pre_carriage" => "boolean",
              "on_carriage" => "boolean",
              "alternative_names" => "string",
              "organization_id" => "string"
            }
          end
        end
      end
    end
  end
end
