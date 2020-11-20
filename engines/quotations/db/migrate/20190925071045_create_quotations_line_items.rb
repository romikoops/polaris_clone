# frozen_string_literal: true

class CreateQuotationsLineItems < ActiveRecord::Migration[5.2]
  def change
    create_table :quotations_line_items, id: :uuid do |t|
      t.uuid :tender_id, index: true, foreign_key: {to_table: :quotations_tenders}
      t.belongs_to :charge_category
      t.monetize :amount, amount: {null: true, default: nil}, currency: {null: true, default: nil}

      t.timestamps
    end
  end
end
