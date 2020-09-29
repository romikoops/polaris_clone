# frozen_string_literal: true

module Migrator
  module Migrations
    module Organizations
      module Themes
        class Update < Base
          TARGET_ATTRIBUTES = %w[emails phones websites email_links addresses].freeze

          def data
            @statements ||= TARGET_ATTRIBUTES.map { |attribute|
              <<~SQL
                UPDATE organizations_themes
                SET #{attribute} = '{}'::json
                WHERE #{attribute} IS NULL
              SQL
            }
          end

          def count_required
            @counts ||= TARGET_ATTRIBUTES.map { |attribute|
              count("
                SELECT COUNT(*)
                FROM organizations_themes
                WHERE #{attribute} IS NULL
              ")
            }
          end
        end
      end
    end
  end
end
