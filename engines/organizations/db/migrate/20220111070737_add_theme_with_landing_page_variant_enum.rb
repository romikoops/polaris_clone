# frozen_string_literal: true

class AddThemeWithLandingPageVariantEnum < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  set_statement_timeout(3000)

  def up
    safety_assured do
      execute <<-SQL
        CREATE TYPE theme_landing_page_variant_type AS ENUM (
          'default',
          'quotation_plugin',
          'light'
        );
      SQL
    end

    add_column :organizations_themes, :landing_page_variant, :theme_landing_page_variant_type
  end

  def down
    remove_column :organizations_themes, :landing_page_variant
    safety_assured do
      execute <<-SQL
        DROP TYPE theme_landing_page_variant_type
      SQL
    end
  end
end
