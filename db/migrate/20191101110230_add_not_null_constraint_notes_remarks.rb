# frozen_string_literal: true

class AddNotNullConstraintNotesRemarks < ActiveRecord::Migration[5.2]
  def change
    change_column_null :notes, :remarks, false
  end
end
