# frozen_string_literal: true

class UpdateThemeLandingPageVariantChangeDefault < ActiveRecord::Migration[5.2]
  def up
    change_column_default :organizations_themes, :landing_page_variant, "default"
  end

  def down
    change_column_default :organizations_themes, :landing_page_variant, nil
  end
end
