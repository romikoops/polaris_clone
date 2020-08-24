# frozen_string_literal: true

class AddWebsitesToOrganizationsTheme < ActiveRecord::Migration[5.2]
  def up
    add_column :organizations_themes, :websites, :jsonb
    change_column_default :organizations_themes, :websites, {}
  end

  def down
    remove_column :organizations_themes, :websites
  end
end
