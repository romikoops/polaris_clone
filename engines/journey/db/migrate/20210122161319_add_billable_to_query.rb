# frozen_string_literal: true
class AddBillableToQuery < ActiveRecord::Migration[5.2]
  def up
    add_column :journey_queries, :billable, :boolean
    change_column_default :journey_queries, :billable, false
  end

  def down
    remove_column :journey_queries, :billable
  end
end
