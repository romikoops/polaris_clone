# frozen_string_literal: true

class ValidateStopForeignKey < ActiveRecord::Migration[5.2]
  def change
    validate_foreign_key :stops, :itineraries
  end
end
