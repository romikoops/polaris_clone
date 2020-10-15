# frozen_string_literal: true

module Migrator
  module Migrations
    module Companies
      module Memberships
        class Update < Base
          def data
            [default, estimated]
          end

          def estimated
            <<~SQL
              UPDATE quotations_quotations
              SET estimated = true
              FROM cargo_cargos
              JOIN cargo_units on cargo_cargos.id = cargo_units.cargo_id
              WHERE quotations_quotations.id = cargo_cargos.quotation_id
              AND cargo_units.weight_value = 1
              AND cargo_units.length_value = 0.01
              AND cargo_units.width_value = 0.01
              AND cargo_units.height_value = 0.01
            SQL
          end

          def default
            <<~SQL
              UPDATE quotations_quotations
              SET estimated = false
            SQL
          end

          def count_required
            [default_count, estimated_count]
          end

          def default_count
            count("
                SELECT COUNT(*)
                FROM quotations_quotations
            ")
          end

          def estimated_count
            count("
                SELECT COUNT(*)
                FROM quotations_quotations
                JOIN cargo_cargos ON quotations_quotations.id = cargo_cargos.quotation_id
                JOIN cargo_units on cargo_cargos.id = cargo_units.cargo_id
                WHERE cargo_units.weight_value = 1
                AND cargo_units.length_value = 0.01
                AND cargo_units.width_value = 0.01
                AND cargo_units.height_value = 0.01
            ")
          end
        end
      end
    end
  end
end
