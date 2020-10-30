# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module DateOverlapConflicts
      module Truckings
        class Metadata < ExcelDataServices::DataFrames::DateOverlapConflicts::Base
          def conflict_keys
            %w[
              hub_id
              carriage
              load_type
              cargo_class
              organization_id
              truck_type
              group_id
              tenant_vehicle_id
              effective_date
              expiration_date
            ]
          end

          def target_table
            model.table_name
          end

          def model
            Trucking::Trucking
          end
        end
      end
    end
  end
end
