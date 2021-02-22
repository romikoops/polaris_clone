# frozen_string_literal: true
class AddStatusToResultSet < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute <<-SQL
        CREATE TYPE journey_status AS ENUM (
          'queued',
          'running',
          'completed');
      SQL
    end

    add_column :journey_result_sets, :status, :journey_status
  end

  def down
    remove_column :journey_result_sets, :status, :journey_status

    execute <<-SQL
      DROP TYPE journey_status
    SQL
  end
end
