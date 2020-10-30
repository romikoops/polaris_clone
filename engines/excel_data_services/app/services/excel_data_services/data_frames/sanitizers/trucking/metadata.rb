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
              "load_meterage_limit" => "decimal",
              "load_meterage_area" => "decimal",
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
              "expiration_date" => "string"
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
              "expiration_date" => today + 1.year
            }
          end

          def default_group
            Groups::Group.find_by(name: "default", organization_id: state.organization_id)
          end

          def today
            @today ||= Time.zone.today
          end
        end
      end
    end
  end
end
