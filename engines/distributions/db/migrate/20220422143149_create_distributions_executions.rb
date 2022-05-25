# frozen_string_literal: true

class CreateDistributionsExecutions < ActiveRecord::Migration[5.2]
  def change
    create_table :distributions_executions, id: :uuid do |t|
      t.references :action, type: :uuid, index: true
      t.uuid :file_id, index: true, null: false
      t.timestamps
    end
  end
end
