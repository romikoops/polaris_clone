# frozen_string_literal: true

class ChangeHubPointSrid < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      exec_update <<~SQL
        SELECT UpdateGeometrySRID('hubs','point',4326);
      SQL
    end
  end
end
