# frozen_string_literal: true

class AddNotNullContraintNotesTransshipment < ActiveRecord::Migration[5.2]
  def change
    change_column_null :notes, :transshipment, false
  end
end
