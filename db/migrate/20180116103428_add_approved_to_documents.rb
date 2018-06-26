# frozen_string_literal: true

class AddApprovedToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :approved, :string
    add_column :documents, :approval_details, :jsonb
  end
end
