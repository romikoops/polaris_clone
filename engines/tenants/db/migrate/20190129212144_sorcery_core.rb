# frozen_string_literal: true

class SorceryCore < ActiveRecord::Migration[5.2]
  def change
    create_table :tenants_users, id: :uuid do |t|
      t.string :email, null: false
      t.string :crypted_password
      t.string :salt

      t.timestamps null: false
    end
  end
end
