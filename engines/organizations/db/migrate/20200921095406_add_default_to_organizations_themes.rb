class AddDefaultToOrganizationsThemes < ActiveRecord::Migration[5.2]
  def change
    change_column_default :organizations_themes, :emails, {}
    change_column_default :organizations_themes, :phones, {}
    change_column_default :organizations_themes, :websites, {}
    change_column_default :organizations_themes, :email_links, {}
    change_column_default :organizations_themes, :addresses, {}
  end
end
