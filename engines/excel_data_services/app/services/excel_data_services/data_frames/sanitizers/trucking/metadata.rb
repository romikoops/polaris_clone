# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Sanitizers
      module Trucking
        class Metadata < ExcelDataServices::DataFrames::Sanitizers::Base
          def sanitizer_lookup
            {
              "city" => "string",
              "currency" => "upcase",
              "load_meterage_ratio" => "decimal",
              "load_meterage_stackable_limit" => "decimal",
              "load_meterage_non_stackable_limit" => "decimal",
              "load_meterage_stackable_type" => "downcase",
              "load_meterage_non_stackable_type" => "downcase",
              "load_meterage_hard_limit" => "boolean",
              "cbm_ratio" => "decimal",
              "scale" => "downcase",
              "rate_basis" => "upcase",
              "base" => "decimal",
              "truck_type" => "downcase",
              "load_type" => "downcase",
              "cargo_class" => "downcase",
              "direction" => "downcase",
              "carrier" => "string",
              "service" => "string",
              "effective_date" => "string",
              "expiration_date" => "string",
              "identifier_modifier" => "string",
              "group_id" => "string",
              "organization_id" => "string",
              "hub_id" => "integer"
            }
          end

          def default_values
            {
              "service" => "standard",
              "carrier" => "",
              "group_id" => default_group.id,
              "identifier_modifier" => false,
              "mode_of_transport" => "truck_carriage",
              "effective_date" => today,
              "expiration_date" => today + 1.year,
              "load_meterage_hard_limit" => false,
              "cbm_ratio" => 0
            }
          end

          def default_group
            Groups::Group.find_by(name: "default", organization_id: Organizations.current_id)
          end

          def today
            @today ||= Time.zone.today
          end
        end
      end
    end
  end
end
