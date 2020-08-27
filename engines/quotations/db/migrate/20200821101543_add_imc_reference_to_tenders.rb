# frozen_string_literal: true

class AddImcReferenceToTenders < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations_tenders, :imc_reference, :string
  end
end
