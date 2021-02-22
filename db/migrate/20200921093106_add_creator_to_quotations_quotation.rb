# frozen_string_literal: true
class AddCreatorToQuotationsQuotation < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations_quotations, :creator_id, :uuid
  end
end
