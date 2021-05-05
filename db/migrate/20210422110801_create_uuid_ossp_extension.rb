# frozen_string_literal: true

class CreateUuidOsspExtension < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute(
        <<-SQL
          CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
        SQL
      )
    end
  end
end
