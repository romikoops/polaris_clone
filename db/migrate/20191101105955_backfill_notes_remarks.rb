# frozen_string_literal: true

class BackfillNotesRemarks < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    Note.unscoped.in_batches do |relation|
      relation.update_all remarks: false
      sleep(0.1)
    end
  end
end
