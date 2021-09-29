# frozen_string_literal: true

class AddMotEnumToSchedules < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute <<-SQL
        CREATE TYPE schedules_mode_of_transport AS ENUM ('ocean', 'air', 'rail', 'truck');
      SQL
    end

    add_column :schedules_schedules, :mode_of_transport, :schedules_mode_of_transport, null: false
  end

  def down
    remove_column :schedules_schedules, :mode_of_transport

    safety_assured do
      execute <<-SQL
        DROP TYPE schedules_mode_of_transport;
      SQL
    end
  end
end
