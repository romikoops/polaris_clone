# frozen_string_literal: true

class AddQuotationToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :quotation_id, :integer
  end
end
