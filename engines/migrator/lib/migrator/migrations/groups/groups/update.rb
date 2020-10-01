module Migrator
  module Migrations
    module Groups
      module Groups
        class Update < Base
          depends_on "groups/groups/prepare"

          MAIN_TABLE_NAMES = %w[local_charges pricings_pricings].freeze

          def data
            [*main_tables, *trucking_tables]
          end

          def main_tables
            MAIN_TABLE_NAMES.map do |table|
              <<~SQL
                UPDATE #{table}
                  SET group_id = groups_groups.id
                FROM groups_groups
                WHERE #{table}.group_id IS NULL
                AND groups_groups.name = 'default'
                AND #{table}.organization_id = groups_groups.organization_id;
              SQL
            end
          end

          def trucking_tables
            org_ids.map do |org_id|
              <<~SQL
                UPDATE trucking_truckings
                  SET group_id = groups_groups.id
                FROM groups_groups
                WHERE trucking_truckings.group_id IS NULL
                AND groups_groups.name = 'default'
                AND trucking_truckings.organization_id = groups_groups.organization_id
                AND trucking_truckings.organization_id = '#{org_id}';
              SQL
            end
          end

          def count_required
            [*main_tables_counts, *trucking_counts]
          end

          def main_tables_counts
            MAIN_TABLE_NAMES.map do |table|
              count("
                SELECT COUNT(*)
                FROM #{table}
                JOIN groups_groups
                ON groups_groups.organization_id = #{table}.organization_id
                WHERE group_id IS NULL
                AND groups_groups.name = 'default';
              ")
            end
          end

          def trucking_counts
            org_ids.map do |org_id|
              count("
                SELECT COUNT(*)
                FROM trucking_truckings
                JOIN groups_groups
                ON groups_groups.organization_id = trucking_truckings.organization_id
                WHERE group_id IS NULL
                AND trucking_truckings.organization_id = '#{org_id}'
                AND groups_groups.name = 'default';
              ")
            end
          end

          def org_ids
            ::Organizations::Organization.order(:id).ids
          end
        end
      end
    end
  end
end
