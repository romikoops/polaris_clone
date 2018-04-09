class ChangeProviderFromUsers < ActiveRecord::Migration[5.1]
  def change
  	change_column_default :users, :provider, "tenant_email"
  end
end
