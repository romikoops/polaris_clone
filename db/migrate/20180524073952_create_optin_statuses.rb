class CreateOptinStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :optin_statuses do |t|
      t.boolean :cookies
      t.boolean :tenant
      t.boolean :itsmycargo
      t.timestamps
    end
  end
end
