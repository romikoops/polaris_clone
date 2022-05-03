# frozen_string_literal: true

class AddDoorkeeperApplicationToDomain < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations_domains, :application_id, :uuid
  end
end
