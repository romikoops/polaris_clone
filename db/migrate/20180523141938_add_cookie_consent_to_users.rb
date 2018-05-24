class AddCookieConsentToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :cookie_consent, :boolean, default: false
  end
end
