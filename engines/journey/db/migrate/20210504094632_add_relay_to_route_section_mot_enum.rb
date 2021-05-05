# frozen_string_literal: true

class AddRelayToRouteSectionMotEnum < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      execute <<-SQL
        ALTER TYPE journey_mode_of_transport ADD VALUE 'relay'
      SQL
    end
  end
end
