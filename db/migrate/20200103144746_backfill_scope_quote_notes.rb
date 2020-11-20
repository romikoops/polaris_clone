# frozen_string_literal: true

class BackfillScopeQuoteNotes < ActiveRecord::Migration[5.2]
  def change
    Tenants::Scope.find_each do |scope|
      next if scope.content["quote_notes"].blank?

      split_notes = scope.content["quote_notes"]
        .split("\n")
        .reject(&:blank?)
        .map { |string| string.squeeze(" ") }

      scope.content["quote_notes"] = split_notes
      scope.save
    end
  end
end
